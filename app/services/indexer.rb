# frozen_string_literal: true

class Indexer
  include Dry::Monads[:result]

  # @param [RSolr::Client] solr
  # @param [String] pid
  def initialize(solr:, pid:)
    @solr = solr
    @pid = pid
    # Give Honeybadger some context in case an error occurs
    Honeybadger.context({ pid: pid })
  end

  # retrieves a single Dor object by pid, indexes the object to solr, does some logging
  # doesn't commit automatically.
  def reindex_pid(add_attributes:, cocina_with_metadata:)
    solr_doc = nil
    logger.info 'document found, now generating document solr'
    # benchmark how long it takes to convert the object to a Solr document
    to_solr_stats = Benchmark.measure('to_solr') do
      solr_doc = if cocina_with_metadata.success?
                   model, metadata = cocina_with_metadata.value!
                   DocumentBuilder.for(model: model, metadata: metadata).to_solr
                 else
                   logger.debug("Fetching fallback indexer because cocina model couldn't be retrieved.")
                   FallbackIndexer.new(id: pid).to_solr
                 end
      logger.debug 'solr doc created'
      @solr.add(solr_doc, add_attributes: add_attributes)
    end.format('%n realtime %rs total CPU %ts').gsub(/[()]/, '')

    logger.info "successfully updated index for #{pid} (metrics: #{to_solr_stats})"

    solr_doc
  end

  # @returns [Success,Failure] the result of finding the model with metadata
  def fetch_model_with_metadata
    cocina_with_metadata = nil
    # benchmark how long it takes to load the object
    load_stats = Benchmark.measure('load_instance') do
      cocina_with_metadata = begin
        Success(Dor::Services::Client.object(pid).find_with_metadata)
      rescue Dor::Services::Client::UnexpectedResponse
        Failure(:conversion_error)
      end
    end.format('%n realtime %rs total CPU %ts').gsub(/[()]/, '')
    logger.info "Load metrics: #{load_stats}"
    cocina_with_metadata
  end

  delegate :logger, to: :Rails
  attr_reader :pid

  def commit
    @solr.commit
  end
end
