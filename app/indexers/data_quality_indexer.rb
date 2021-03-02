# frozen_string_literal: true

class DataQualityIndexer
  attr_reader :resource

  def initialize(resource:, cocina:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    Rails.logger.debug "In #{self.class}"
    # Filter out Items that were attachments for ETDs/EEMs.  These aren't getting migrated.
    return {} if filtered_object?

    { 'data_quality_ssim' => messages }
  end

  private

  # @return [Boolean] true if the object is an obsolete type that was used for Eems or Etds.
  #                        these will not be migrated as they are ephemeral and not preserved.
  # rubocop:disable Style/MultipleComparison
  def filtered_object?
    # conforms_to is used on earlier ETD objects and later objects used has_model
    return true if resource.relationships(:conforms_to) == ['info:fedora/afmodel:Part']

    model = resource.relationships(:has_model)
    # Etd used Part for everything and Eems used PermissionFile
    model == ['info:fedora/afmodel:Part'] || model == ['info:fedora/afmodel:PermissionFile']
  end
  # rubocop:enable Style/MultipleComparison

  def messages
    [source_id_message].compact.tap do |messages|
      messages << 'Cocina conversion failed'
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
