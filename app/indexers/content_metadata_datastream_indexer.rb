# frozen_string_literal: true

class ContentMetadataDatastreamIndexer
  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for contentMetadata
  def to_solr
    resource.contentMetadata.to_solr
  end
end
