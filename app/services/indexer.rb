# frozen_string_literal: true

class Indexer
  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    DataIndexer,
    RoleMetadataDatastreamIndexer,
    AdministrativeMetadataDatastreamIndexer,
    DefaultObjectRightsDatastreamIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    EventsDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    EditableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    EventsDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ETD_INDEXER = CompositeIndexer.new(
    DataIndexer,
    EtdPropertiesDatastreamIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    EventsDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    EmbargoMetadataDatastreamIndexer,
    ContentMetadataDatastreamIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    EventsDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    EmbargoMetadataDatastreamIndexer,
    ContentMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    EventsDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  INDEXERS = {
    Dor::Agreement => ITEM_INDEXER, # Agreement uses same indexer as Dor::Item
    Dor::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Collection => COLLECTION_INDEXER,
    Dor::Etd => ETD_INDEXER,
    Hydrus::Item => ITEM_INDEXER,
    Hydrus::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Item => ITEM_INDEXER,
    Dor::Set => SET_INDEXER
  }.freeze

  def self.for(obj)
    INDEXERS.fetch(obj.class).new(resource: obj)
  end
end
