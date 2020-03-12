# frozen_string_literal: true

class RoleMetadataDatastreamIndexer
  attr_reader :resource
  def initialize(resource:, cocina:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for roleMetadata
  def to_solr
    resource.roleMetadata.to_solr
  end
end
