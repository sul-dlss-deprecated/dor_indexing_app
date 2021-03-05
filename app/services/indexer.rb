# frozen_string_literal: true

require 'dry/monads/maybe'

class Indexer
  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RoleMetadataDatastreamIndexer,
    AdministrativeMetadataDatastreamIndexer,
    DefaultObjectRightsDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataDatastreamIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataDatastreamIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    EmbargoMetadataDatastreamIndexer,
    ContentMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataDatastreamIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  # This indexer is used when dor-services-app is unable to produce a cocina representation of the object
  FALLBACK_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    ReleasableIndexer,
    WorkflowsIndexer,
    Fedora3LabelIndexer
  )

  INDEXERS = {
    Dor::Agreement => ITEM_INDEXER, # Agreement uses same indexer as Dor::Item
    Dor::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Collection => COLLECTION_INDEXER,
    Hydrus::Item => ITEM_INDEXER,
    Hydrus::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Item => ITEM_INDEXER,
    Dor::Set => SET_INDEXER
  }.freeze

  # @param [Dor::Abstract] obj
  # @param [Dry::Monads::Result] cocina_with_metadata
  def self.for(obj, cocina_with_metadata:)
    Rails.logger.debug("Fetching indexer for #{obj.class}")
    if cocina_with_metadata.success?
      model, metadata = cocina_with_metadata.value!
      INDEXERS.fetch(obj.class).new(id: model.externalIdentifier, resource: obj, cocina: model, metadata: metadata)
    else
      FALLBACK_INDEXER.new(id: obj.pid, resource: obj, cocina: cocina_with_metadata.to_maybe)
    end
  end
end
