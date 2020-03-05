# frozen_string_literal: true

class IdentityMetadataDatastreamIndexer
  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    resource.identityMetadata.to_solr
  end
end
