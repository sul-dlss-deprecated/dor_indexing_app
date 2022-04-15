# frozen_string_literal: true

class CollectionTitleIndexer
  attr_reader :cocina, :parent_collections, :administrative_tags

  def initialize(cocina:, parent_collections:, administrative_tags:, **)
    @cocina = cocina
    @parent_collections = parent_collections
    @administrative_tags = administrative_tags
  end

  # @return [Hash] the partial solr document for identifiable concerns
  def to_solr
    Rails.logger.debug { "In #{self.class}" }

    {}.tap do |solr_doc|
      parent_collections.each do |related_obj|
        title = Cocina::Models::TitleBuilder.build(related_obj.description.title)

        if part_of_project_hydrus?
          # create/append hydrus_collection_title_ssim
          ::Solrizer.insert_field(solr_doc, 'hydrus_collection_title', title, :symbol)
        else
          # create/append nonhydrus_collection_title_ssim
          ::Solrizer.insert_field(solr_doc, 'nonhydrus_collection_title', title, :symbol)
        end
        # create/append collection_title_tesim and collection_title_ssim
        ::Solrizer.insert_field(solr_doc, 'collection_title', title, :stored_searchable, :symbol)
      end
    end
  end

  def part_of_project_hydrus?
    administrative_tags.include?('Project : Hydrus')
  end
end
