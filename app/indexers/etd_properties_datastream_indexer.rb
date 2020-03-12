# frozen_string_literal: true

class EtdPropertiesDatastreamIndexer
  attr_reader :resource
  def initialize(resource:, cocina:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for the properties
  def to_solr
    # Namely this does `title_tesim`
    resource.properties.to_solr
  end
end
