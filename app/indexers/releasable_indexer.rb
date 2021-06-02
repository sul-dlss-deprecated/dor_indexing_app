# frozen_string_literal: true

class ReleasableIndexer
  include SolrDocHelper

  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for releasable concerns
  # TODO: sort of worried about the performance impact in bulk reindex
  # situations, since released_for recurses all parent collections.  jmartin 2015-07-14
  def to_solr
    Rails.logger.debug "In #{self.class}"
    values = released_for.group_by(&:to).map do |project, releases_for_project|
      project if releases_for_project.max_by(&:date).release
    end.compact

    return {} if values.blank?

    {
      'released_to_ssim' => values
    }
  end

  private

  def released_for
    Array(cocina.administrative.releaseTags)
  end
end
