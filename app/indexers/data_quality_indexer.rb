# frozen_string_literal: true

class DataQualityIndexer
  attr_reader :resource, :cocina

  def initialize(resource:, cocina:)
    @resource = resource
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    Rails.logger.debug "In #{self.class}"

    { 'data_quality_ssim' => messages }
  end

  private

  def messages
    [source_id_message].compact.tap do |messages|
      messages << 'Cocina conversion failed' if cocina.failure?
    end
  end

  def source_id_message
    if source_id.present?
      'non-comformant sourceId' unless valid_source_id?
    else
      'missing sourceId'
    end
  end

  def source_id
    @source_id ||= resource.identityMetadata.sourceId
  end

  def valid_source_id?
    /^.+:.+$/.match?(source_id)
  end
end
