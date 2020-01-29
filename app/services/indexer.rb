# frozen_string_literal: true

class Indexer
  WORKFLOW_INDEXER = CompositeIndexer.new(
    DataIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    DataIndexer,
    DescribableIndexer,
    EditableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    DataIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ETD_INDEXER = CompositeIndexer.new(
    DataIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    DataIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    DataIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  INDEXERS = {
    Dor::Agreement => ITEM_INDEXER, # Agreement uses same indexer as Dor::Item
    Dor::WorkflowObject => WORKFLOW_INDEXER,
    Dor::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Collection => COLLECTION_INDEXER,
    Dor::Etd => ETD_INDEXER,
    Dor::Item => ITEM_INDEXER,
    Dor::Set => SET_INDEXER
  }.freeze

  def self.for(obj)
    INDEXERS.fetch(obj.class).new(resource: obj)
  end
end
