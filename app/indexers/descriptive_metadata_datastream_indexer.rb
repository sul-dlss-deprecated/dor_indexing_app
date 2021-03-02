# frozen_string_literal: true

class DescriptiveMetadataDatastreamIndexer
  attr_reader :cocina

  def initialize(resource:, cocina:)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for descMetadata
  def to_solr
    topics = Array(cocina.description.subject).select { |node| node.type == 'topic' }.map(&:value)
    {
      'topic_ssim' => topics,
      'topic_tesim' => topics
    }
  end
end
