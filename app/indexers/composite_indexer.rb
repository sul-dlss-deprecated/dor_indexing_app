# frozen_string_literal: true

# Borrowed from https://github.com/samvera/valkyrie/blob/master/lib/valkyrie/persistence/solr/composite_indexer.rb
class CompositeIndexer
  attr_reader :indexers

  def initialize(*indexers)
    @indexers = indexers
  end

  def new(id:, resource:, cocina:)
    Instance.new(indexers, id: id, resource: resource, cocina: cocina)
  end

  class Instance
    attr_reader :indexers

    def initialize(indexers, id:, resource:, cocina:)
      @indexers = indexers.map do |i|
        i.new(id: id, resource: resource, cocina: cocina)
      rescue ArgumentError => e
        raise ArgumentError, "Unable to initialize #{i}. #{e.message}"
      end
    end

    # @return [Hash] the merged solr document for all the sub-indexers
    def to_solr
      indexers.map(&:to_solr).inject({}, &:merge)
    end
  end
end
