# frozen_string_literal: true

class IdentityMetadataIndexer
  attr_reader :cocina_object

  def initialize(cocina:, **)
    @cocina_object = cocina
  end

  # @return [Hash] the partial solr document for identityMetadata
  def to_solr
    return { 'objectType_ssim' => [object_type] } if object_type == 'adminPolicy' || cocina_object.identification.nil?

    {
      'objectType_ssim' => [object_type],
      'dor_id_tesim' => [source_id_value, barcode, catkey, folio_instance_hrid, previous_ils_ids].flatten.compact,
      'identifier_ssim' => prefixed_identifiers,
      'identifier_tesim' => prefixed_identifiers,
      'barcode_id_ssim' => [barcode].compact,
      'catkey_id_ssim' => [catkey].compact,
      'source_id_ssim' => [source_id].compact,
      'folio_instance_hrid_ssim' => [folio_instance_hrid].compact
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
    @barcode ||= object_type == 'collection' ? nil : cocina_object.identification.barcode
  end

  def catkey
    @catkey ||= Array(cocina_object.identification.catalogLinks).find { |link| link.catalog == 'symphony' }&.catalogRecordId
  end

  def previous_catkeys
    @previous_catkeys ||=
      Array(cocina_object.identification.catalogLinks).filter_map { |link| link.catalogRecordId if link.catalog == 'previous symphony' }
  end

  def folio_instance_hrid
    @folio_instance_hrid ||= Array(cocina_object.identification.catalogLinks).find { |link| link.catalog == 'folio' }&.catalogRecordId
  end

  def previous_folio_instance_hrids
    @previous_folio_instance_hrids ||=
      Array(cocina_object.identification.catalogLinks).filter_map { |link| link.catalogRecordId if link.catalog == 'previous folio' }
  end

  def previous_ils_ids
    @previous_ils_ids ||= previous_catkeys + previous_folio_instance_hrids
  end

  def object_type
    case cocina_object
    when Cocina::Models::AdminPolicyWithMetadata
      'adminPolicy'
    when Cocina::Models::CollectionWithMetadata
      'collection'
    else
      cocina_object.type == Cocina::Models::ObjectType.agreement ? 'agreement' : 'item'
    end
  end

  def prefixed_identifiers
    [].tap do |identifiers|
      identifiers << source_id if source_id
      identifiers << "barcode:#{barcode}" if barcode
      identifiers << "catkey:#{catkey}" if catkey
      identifiers << "folio:#{folio_instance_hrid}" if folio_instance_hrid
    end
  end
end
