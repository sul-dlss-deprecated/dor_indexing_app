# frozen_string_literal: true

class DescriptiveMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for descMetadata
  def to_solr
    {
      'originInfo_date_created_tesim' => creation&.date&.map(&:value),
      'originInfo_publisher_tesim' => publisher_name,
      'originInfo_place_placeTerm_tesim' => publication&.location&.map(&:value),
      'topic_ssim' => topics,
      'topic_tesim' => topics
    }
  end

  private

  def publisher_name
    publisher = Array(publication&.contributor).find { |contributor| contributor.role.any? { |role| role.value == 'publisher' } }
    Array(publisher&.name).map(&:value)
  end

  def publication
    @publication ||= events.find { |node| node.type == 'publication' }
  end

  def creation
    events.find { |node| node.type == 'creation' }
  end

  def topics
    @topics ||= Array(cocina.description.subject).select { |node| node.type == 'topic' }.map(&:value)
  end

  def events
    @events ||= Array(cocina.description.event)
  end
end
