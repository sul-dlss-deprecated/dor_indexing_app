# frozen_string_literal: true

class IdentifiableIndexer
  include SolrDocHelper

  INDEX_VERSION_FIELD = 'dor_services_version_ssi'

  FIELDS = {
    collection: {
      hydrus: 'hydrus_collection_title',
      non_hydrus: 'nonhydrus_collection_title',
      union: 'collection_title'
    },
    apo: {
      hydrus: 'hydrus_apo_title',
      non_hydrus: 'nonhydrus_apo_title',
      union: 'apo_title'
    }
  }.freeze
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  ## Module-level variables, shared between ALL mixin includers (and ALL *their* includers/extenders)!
  ## used for caching found values
  @@collection_hash = {}
  @@apo_hash = {}

  # @return [Hash] the partial solr document for identifiable concerns
  def to_solr
    Rails.logger.debug "In #{self.class}"

    solr_doc = {}
    solr_doc[INDEX_VERSION_FIELD] = Dor::VERSION

    solrize_related_obj_titles(solr_doc, [cocina.administrative.hasAdminPolicy].compact, @@apo_hash, :apo)

    if cocina.is_a? Cocina::Models::DRO
      collection_ids = Array(cocina.structural.isMemberOf)
      solrize_related_obj_titles(solr_doc, collection_ids, @@collection_hash, :collection)
    end

    solr_doc['metadata_source_ssi'] = identity_metadata_source unless cocina.is_a? Cocina::Models::AdminPolicy
    # This used to be added to the index by https://github.com/sul-dlss/dor-services/commit/11b80d249d19326ef591411ffeb634900e75c2c3
    # and was called dc_identifier_druid_tesim
    # It is used to search based on druid.
    solr_doc['objectId_tesim'] = [cocina.externalIdentifier, cocina.externalIdentifier.delete_prefix('druid:')]
    solr_doc
  end

  # @return [String] calculated value for Solr index
  def identity_metadata_source
    if cocina.identification.catalogLinks.any? { |link| link.catalog == 'symphony' }
      'Symphony'
    else
      'DOR'
    end
  end

  # Clears out the cache of items. Used primarily in testing.
  def self.reset_cache!
    @@collection_hash = {}
    @@apo_hash = {}
  end

  private

  # @param [Hash] solr_doc
  # @param [Array] relationships
  # @param [Hash] title_cache a cache for titles
  # @param [Symbol] type either :apo or :collection
  def solrize_related_obj_titles(solr_doc, relationships, title_cache, type)
    # TODO: if you wanted to get a little fancier, you could also solrize a 2 level hierarchy and display using hierarchial facets, like
    # ["SOURCE", "SOURCE : TITLE"] (e.g. ["Hydrus", "Hydrus : Special Collections"], see (exploded) tags in IdentityMetadataDS#to_solr).
    title_type = :symbol # we'll get an _ssim because of the type
    title_attrs = [:stored_searchable] # we'll also get a _tesim from this attr (TODO, this is only needed for collection_title_tesim)
    relationships.each do |rel_druid|
      populate_cache(title_cache, rel_druid, type)

      # cache should definitely be populated, so just use that to write solr field
      if title_cache[rel_druid]['is_from_hydrus']
        add_solr_value(solr_doc, FIELDS.dig(type, :hydrus), title_cache[rel_druid]['related_obj_title'], title_type, title_attrs)
      else
        add_solr_value(solr_doc, FIELDS.dig(type, :non_hydrus), title_cache[rel_druid]['related_obj_title'], title_type, title_attrs)
      end
      add_solr_value(solr_doc, FIELDS.dig(type, :union), title_cache[rel_druid]['related_obj_title'], title_type, title_attrs)
    end
  end

  # populate cache if necessary
  def populate_cache(title_cache, rel_druid, type)
    return if title_cache.key?(rel_druid)

    begin
      related_obj = Dor::Services::Client.object(rel_druid).find
      # APOs don't have projects, and since Hydrus is set to be retired, I don't want to
      # add the cocina property. Just check the tags service instead.
      is_from_hydrus = type == :apo ? has_hydrus_tag?(rel_druid) : related_obj.administrative.partOfProject == 'Hydrus'
      title_cache[rel_druid] = { 'related_obj_title' => related_obj.label, 'is_from_hydrus' => is_from_hydrus }
    rescue Dor::Services::Client::UnexpectedResponse, Dor::Services::Client::NotFoundResponse
      Honeybadger.notify("Bad association found on #{cocina.externalIdentifier}. #{rel_druid} could not be found")
      # This may happen if the given APO or Collection does not exist (bad data)
      title_cache[rel_druid] = { 'related_obj_title' => rel_druid, 'is_from_hydrus' => false }
    end
  end

  def has_hydrus_tag?(id)
    Dor::Services::Client.object(id).administrative_tags.list.include?('Project : Hydrus')
  end
end
