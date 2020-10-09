# frozen_string_literal: true

# Borrowed from https://github.com/samvera/valkyrie/blob/master/lib/valkyrie/persistence/solr/composite_indexer.rb
class CompositeIndexer
  attr_reader :indexers

  def initialize(*indexers)
    @indexers = indexers
  end

  def new(resource:, cocina:)
    Instance.new(indexers, resource: resource, cocina: cocina)
  end

  class Instance
    attr_reader :indexers, :resource

    def initialize(indexers, resource:, cocina:)
      @resource = resource
      @indexers = indexers.map { |i| i.new(resource: resource, cocina: cocina) }
    end

    # @return [Hash] the merged solr document for all the sub-indexers
    def to_solr
      indexers.map(&:to_solr).inject({}, &:merge)
    end
  end
end
