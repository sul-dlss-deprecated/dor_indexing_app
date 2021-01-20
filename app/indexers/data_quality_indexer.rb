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
    # Filter out Items that were attachments for ETDs.  These aren't getting migrated.
    return {} if etd_part?

    { 'data_quality_ssim' => messages }
  end

  private

  def etd_part?
    # conforms_to is used on earlier objects and later has_model was used
    resource.relationships(:conforms_to) == ['info:fedora/afmodel:Part'] ||
      resource.relationships(:has_model) == ['info:fedora/afmodel:Part']
  end

  def messages
    [source_id_message].compact.tap do |messages|
      messages << 'Cocina conversion failed' if cocina.failure?
    end
  end

  def source_id_message
    if source_id.present?
      'non-comformant sourceId' unless valid_source_id?
    elsif resource.is_a?(Dor::Item) # Collections and APOs are not required to have a sourceId
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
