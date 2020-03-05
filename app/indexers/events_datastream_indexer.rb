# frozen_string_literal: true

class EventsDatastreamIndexer
  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for events
  def to_solr
    resource.events.to_solr
  end
end
