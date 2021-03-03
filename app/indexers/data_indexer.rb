# frozen_string_literal: true

# Indexing provided by ActiveFedora
class DataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  def to_solr
    {}.tap do |solr_doc|
      Rails.logger.debug "In #{self.class}"
      solr_doc[SOLR_DOCUMENT_ID.to_sym] = cocina.externalIdentifier

      # These are required as long as dor-services-app uses ActiveFedora for querying:
      solr_doc['has_model_ssim'] = legacy_model
      solr_doc['is_governed_by_ssim'] = legacy_apo
      solr_doc['is_member_of_collection_ssim'] = legacy_collections
    end
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
