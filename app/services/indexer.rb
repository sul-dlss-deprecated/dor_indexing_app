# frozen_string_literal: true

class Indexer
  # @param [RSolr::Client] solr
  # @param [String] identifier for cocina object
  # @param [Integer] commit within milliseconds; if nil, then immediately committed.
  # @raise [Dor::Services::Client::NotFoundResponse]
  # @raise [Dor::Services::Client::UnexpectedResponse]
  # @return [Hash,Nil] solr document or nil if indexing failed
  def self.load_and_index(solr:, identifier:, commit_within: 1000)
    new(solr: solr, commit_within: commit_within).load_and_index(identifier: identifier)
  end

  # @param [RSolr::Client] solr
  # @param [Cocina::Models::DROWithMetadata|CollectionWithMetadata|AdminPolicyWithMetadata] cocina object to index
  # @param [Integer] commit within milliseconds; if nil, then immediately committed.
  # @return [Hash,Nil] solr document or nil if indexing failed
  def self.reindex(solr:, cocina_with_metadata:, commit_within: 1000)
    new(solr: solr, commit_within: commit_within).reindex(cocina_with_metadata: cocina_with_metadata)
  end

  # @param [RSolr::Client] solr
  # @param [String] identifier for cocina object
  # @param [Integer] commit within milliseconds; if nil, then immediately committed.
  # @return [Hash,Nil] solr document or nil if indexing failed
  def self.delete(solr:, identifier:, commit_within: 1000)
    new(solr: solr, commit_within: commit_within).delete(identifier: identifier)
  end

  def initialize(solr:, commit_within: 1000)
    @solr = solr
    @commit_within = commit_within
  end

  def load_and_index(identifier:)
    Honeybadger.context({ identifier: identifier })
    cocina_with_metadata = Dor::Services::Client.object(identifier).find
    reindex(cocina_with_metadata: cocina_with_metadata)
  end

  # Indexes the provided Cocina object to solr
  def reindex(cocina_with_metadata:)
    Honeybadger.context({ identifier: cocina_with_metadata.externalIdentifier })

    solr_doc = DocumentBuilder.for(model: cocina_with_metadata).to_solr
    logger.debug 'solr doc created'
    solr.add(solr_doc, add_attributes: { commitWithin: commit_within || 1000 })
    solr.commit if commit_within.nil?

    logger.info "successfully updated index for #{cocina_with_metadata.externalIdentifier}"

    solr_doc
  end

  def delete(identifier:)
    solr.delete_by_id(identifier, commitWithin: commit_within || 1000)
    solr.commit if commit_within.nil?

    logger.info "successfully deleted #{identifier}"
  end

  private

  delegate :logger, to: :Rails
  attr_reader :solr, :commit_within
end
