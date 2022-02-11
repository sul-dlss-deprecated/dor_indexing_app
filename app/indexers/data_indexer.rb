# frozen_string_literal: true

# Indexing provided by ActiveFedora
class DataIndexer
  attr_reader :metadata, :cocina

  def initialize(metadata:, cocina:, **)
    @metadata = metadata
    @cocina = cocina
  end

  def to_solr
    {}.tap do |solr_doc|
      Rails.logger.debug { "In #{self.class}" }
      solr_doc[:id] = cocina.externalIdentifier
      solr_doc['current_version_isi'] = cocina.version # Argo Facet field "Version"
      solr_doc['obj_label_tesim'] = cocina.label

      solr_doc['modified_latest_dttsi'] = modified_latest
      solr_doc['created_at_dttsi'] = created_at

      # These are required as long as dor-services-app uses ActiveFedora for querying:
      solr_doc['has_model_ssim'] = legacy_model
      solr_doc['is_governed_by_ssim'] = legacy_apo
      solr_doc['is_member_of_collection_ssim'] = legacy_collections

      # Used so that DSA can generate public XML whereas a constituent can find the virtual object it is part of.
      solr_doc['has_constituents_ssim'] = virtual_object_constituents
    end.merge(WorkflowFields.for(druid: cocina.externalIdentifier, version: cocina.version))
  end

  def modified_latest
    metadata.updated_at.to_datetime.strftime('%FT%TZ')
  end

  def created_at
    metadata.created_at.to_datetime.strftime('%FT%TZ')
  end

  def legacy_collections
    case cocina.type
    when Cocina::Models::Vocab.admin_policy, Cocina::Models::Vocab.collection
      []
    else
      Array(cocina.structural.isMemberOf).map { |col_id| "info:fedora/#{col_id}" }
    end
  end

  def virtual_object_constituents
    return unless cocina.dro?

    cocina.structural.hasMemberOrders.first&.members
  end

  def legacy_apo
    "info:fedora/#{cocina.administrative.hasAdminPolicy}"
  end

  def legacy_model
    case cocina.type
    when Cocina::Models::Vocab.admin_policy
      'info:fedora/afmodel:Dor_AdminPolicyObject'
    when Cocina::Models::Vocab.collection
      'info:fedora/afmodel:Dor_Collection'
    else
      'info:fedora/afmodel:Dor_Item'
    end
  end
end
