# frozen_string_literal: true

require 'dry/monads/maybe'

class Indexer
  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RoleMetadataIndexer,
    DefaultObjectRightsIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    EmbargoMetadataIndexer,
    ContentMetadataIndexer,
    IdentifiableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  INDEXERS = {
    Cocina::Models::Vocab.agreement => ITEM_INDEXER, # Agreement uses same indexer as item
    Cocina::Models::Vocab.admin_policy => ADMIN_POLICY_INDEXER,
    Cocina::Models::Vocab.collection => COLLECTION_INDEXER
  }.freeze

  # @param [Cocina::Models::DRO,Cocina::Models::Collection,Cocina::Model::AdminPolicy] model
  # @param [Hash<String,String>] metadata
  def self.for(model:, metadata:)
    Rails.logger.debug("Fetching indexer for #{model.type}")
    INDEXERS.fetch(model.type, ITEM_INDEXER).new(id: model.externalIdentifier, cocina: model, metadata: metadata)
  end
end
