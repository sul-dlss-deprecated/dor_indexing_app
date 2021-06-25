# frozen_string_literal: true

class DataQualityIndexer
  attr_reader :resource

  def initialize(resource:, **)
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
  def filtered_object?
    # conformsTo is used on earlier ETD objects and later objects used has_model
    return true if conforms_to_part?

    # Etd used Part for everything and Eems used PermissionFile
    model == ['info:fedora/afmodel:Part'] || model == ['info:fedora/afmodel:PermissionFile']
  end

  def model
    @model ||= resource.models.select { |model| model.start_with? 'info:fedora/afmodel' }
  end

  def messages
    [source_id_message].compact.tap do |messages|
      messages << 'Cocina conversion failed'
    end
  end

  def source_id_message
    if source_id.present?
      'non-comformant sourceId' unless valid_source_id?
    elsif model == ['info:fedora/afmodel:Dor_Item'] # Collections and APOs are not required to have a sourceId
      'missing sourceId'
    end
  end

  def conforms_to_part?
    resource.datastreams['RELS-EXT'].content.body.include?('conformsTo rdf:resource="info:fedora/afmodel:Part"')
  end

  def source_id
    @source_id ||= source_node ? [source_node['source'], source_node.text].join(':') : nil
  end

  def source_node
    @source_node ||= identity_metadata&.xpath('//identityMetadata/sourceId')&.first
  end

  def identity_metadata
    response = resource.datastreams['identityMetadata'].content
    return unless response

    Nokogiri::XML(response.body)
  end

  def valid_source_id?
    /^.+:.+$/.match?(source_id)
  end
end
