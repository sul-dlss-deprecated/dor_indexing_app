# frozen_string_literal: true

class IdentityMetadataDatastreamIndexer
  include SolrDocHelper

  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    solr_doc = {}
    solr_doc['objectType_ssim'] = resource.identityMetadata.objectType
    solr_doc['tag_ssim'] = resource.identityMetadata.tag

    if resource.identityMetadata.sourceId.present?
      (name, id) = resource.identityMetadata.sourceId.split(/:/, 2)
      add_solr_value(solr_doc, 'dor_id', id, :symbol, [:stored_searchable])
      add_solr_value(solr_doc, 'identifier', resource.identityMetadata.sourceId, :symbol, [:stored_searchable])
      add_solr_value(solr_doc, 'source_id', resource.identityMetadata.sourceId, :symbol, [])
    end
    resource.identityMetadata.otherId.compact.each do |qid|
      # this section will solrize barcode and catkey, which live in otherId
      (name, id) = qid.split(/:/, 2)
      add_solr_value(solr_doc, 'dor_id', id, :symbol, [:stored_searchable])
      add_solr_value(solr_doc, 'identifier', qid, :symbol, [:stored_searchable])
      next unless %w[barcode catkey].include?(name)

      add_solr_value(solr_doc, "#{name}_id", id, :symbol, [])
    end

    # do some stuff to make tags in general and project tags specifically more easily searchable and facetable
    # rubocop:disable Rails/DynamicFindBy
    resource.identityMetadata.find_by_terms(:tag).each do |tag|
      (prefix, rest) = tag.text.split(/:/, 2)
      prefix = prefix.downcase.strip.gsub(/\s/, '_')
      unless rest.nil?
        # this part will index a value in a field specific to the tag, e.g. registered_by_tag_*,
        # book_tag_*, project_tag_*, remediated_by_tag_*, etc.  project_tag_* and registered_by_tag_*
        # definitley get used, but most don't.  we can limit the prefixes that get solrized if things
        # get out of hand.
        add_solr_value(solr_doc, "#{prefix}_tag", rest.strip, :symbol, [])
      end

      # solrize each possible prefix for the tag, inclusive of the full tag.
      # e.g., for a tag such as "A : B : C", this will solrize to an _ssim field
      # that contains ["A",  "A : B",  "A : B : C"].
      tag_parts = tag.text.split(/:/)
      progressive_tag_prefix = ''
      tag_parts.each_with_index do |part, index|
        progressive_tag_prefix += ' : ' if index > 0
        progressive_tag_prefix += part.strip
        add_solr_value(solr_doc, 'exploded_tag', progressive_tag_prefix, :symbol, [])
      end
    end
    # rubocop:enable Rails/DynamicFindBy

    solr_doc
  end
end
