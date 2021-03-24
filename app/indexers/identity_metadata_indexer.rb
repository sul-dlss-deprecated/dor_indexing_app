# frozen_string_literal: true

class IdentityMetadataIndexer
  include SolrDocHelper

  attr_reader :cocina_object

  def initialize(cocina:, **)
    @cocina_object = cocina
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    return { 'objectType_ssim' => [object_type] } if object_type == 'adminPolicy' || cocina_object.identification.nil?

    {
      'objectType_ssim' => [object_type],
      'dor_id_tesim' => [source_id_value, barcode, catkey].compact,
      'identifier_ssim' => prefixed_identifiers,
      'identifier_tesim' => prefixed_identifiers,
      'barcode_id_ssim' => [barcode].compact,
      'catkey_id_ssim' => [catkey].compact,
      'source_id_ssim' => [source_id].compact
    }
  end

  private

  def source_id
    @source_id ||= cocina_object.identification.sourceId
  end

  def source_id_value
    @source_id_value ||= source_id ? source_id.split(/:/, 2)[1] : nil
  end

  def barcode
    @barcode ||= cocina_object.identification.barcode
  end

  def catkey
    @catkey ||= Array(cocina_object.identification.catalogLinks).find { |link| link.catalog == 'symphony' }&.catalogRecordId
  end

  def object_type
    case cocina_object
    when Cocina::Models::AdminPolicy
      'adminPolicy'
    when Cocina::Models::Collection
      'collection'
    else
      'item'
    end
  end

  def prefixed_identifiers
    [].tap do |identifiers|
      identifiers << source_id if source_id
      identifiers << "barcode:#{barcode}" if barcode
      identifiers << "catkey:#{catkey}" if catkey
    end
  end
end
