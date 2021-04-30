# frozen_string_literal: true

# Indexing provided by ActiveFedora
class DataIndexer
  attr_reader :last_modified, :cocina

  def initialize(metadata:, cocina:, **)
    @last_modified = metadata.fetch('Last-Modified')
    @cocina = cocina
  end

  def to_solr
    {}.tap do |solr_doc|
      Rails.logger.debug "In #{self.class}"
      solr_doc[:id] = cocina.externalIdentifier
      solr_doc['current_version_isi'] = cocina.version # Argo Facet field "Version"
      solr_doc['obj_label_tesim'] = cocina.label

      solr_doc['modified_latest_dttsi'] = last_modified.to_datetime.strftime('%FT%TZ')

      # These are required as long as dor-services-app uses ActiveFedora for querying:
      solr_doc['has_model_ssim'] = legacy_model
      solr_doc['is_governed_by_ssim'] = legacy_apo
      solr_doc['is_member_of_collection_ssim'] = legacy_collections
    end.merge(WorkflowFields.for(druid: cocina.externalIdentifier, version: cocina.version))
  end

  def legacy_collections
    case cocina.type
    when Cocina::Models::Vocab.admin_policy, Cocina::Models::Vocab.collection
      []
    else
      Array(cocina.structural.isMemberOf).map { |col_id| "info:fedora/#{col_id}" }
    end
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
