# frozen_string_literal: true

class ReleasableIndexer
  include SolrDocHelper

  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for releasable concerns
  def to_solr
    Rails.logger.debug "In #{self.class}"
    solr_doc = {}

    # TODO: sort of worried about the performance impact in bulk reindex
    # situations, since released_for recurses all parent collections.  jmartin 2015-07-14
    released_for.each do |directive|
      add_solr_value(solr_doc, 'released_to', directive.to, :symbol, []) if directive.release
    end

    # TODO: need to solrize whether item is released to purl?  does released_for return that?
    # logic is: "True when there is a published lifecycle and Access Rights is anything but Dark"

    solr_doc
  end

  private

  def released_for
    cocina.administrative.releaseTags
  end
end
