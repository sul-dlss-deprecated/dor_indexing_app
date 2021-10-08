# frozen_string_literal: true

class ReleasableIndexer
  attr_reader :cocina, :parent_collections

  def initialize(cocina:, parent_collections:, **)
    @cocina = cocina
    @parent_collections = parent_collections
  end

  # @return [Hash] the partial solr document for releasable concerns
  def to_solr
    Rails.logger.debug "In #{self.class}"
    values = tags_from_item + tags_from_collection

    return {} if values.blank?

    {
      'released_to_ssim' => values.uniq
    }
  end

  private

  def tags_from_collection
    parent_collections.flat_map do |collection|
      Array(collection.administrative.releaseTags)
        .select { |tag| tag.what == 'collection' }
        .group_by(&:to).map do |project, releases_for_project|
          project if releases_for_project.max_by(&:date).release
        end.compact
    end
  end

  def tags_from_item
    released_for.group_by(&:to).map do |project, releases_for_project|
      project if releases_for_project.max_by(&:date).release
    end.compact
  end

  def released_for
    Array(cocina.administrative.releaseTags)
  end
end
