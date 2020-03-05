# frozen_string_literal: true

class EmbargoMetadataDatastreamIndexer
  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for embargoMetadata
  def to_solr
    resource.embargoMetadata.to_solr
  end
end
