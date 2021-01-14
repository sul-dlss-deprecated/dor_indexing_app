# frozen_string_literal: true

# Main controller of application
class DorController < ApplicationController
  include Dry::Monads[:result]

  def reindex
    @solr_doc = reindex_pid params[:pid], add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i }
    solr.commit unless params[:commitWithin] # reindex_pid doesn't commit, but callers of this method may expect the update to be committed immediately
    render status: 200, plain: "Successfully updated index for #{params[:pid]}"
  rescue ActiveFedora::ObjectNotFoundError # => e
    render status: 404, plain: 'Object does not exist in Fedora.'
  end

  def delete_from_index
    solr.delete_by_id(params[:pid], commitWithin: params.fetch(:commitWithin, 1000).to_i)
    solr.commit unless params[:commitWithin]
    render plain: params[:pid]
  end

  def queue_size
    render status: 200, json: { value: QueueStatus.all.queue_size }
  end

  private

  # retrieves a single Dor object by pid, indexes the object to solr, does some logging
  # doesn't commit automatically.
  def reindex_pid(pid, add_attributes:)
    obj = nil
    solr_doc = nil
    cocina = nil

    # benchmark how long it takes to load the object
    load_stats = Benchmark.measure('load_instance') do
      obj = Dor.find pid
      cocina = begin
        Success(Dor::Services::Client.object(pid).find)
      rescue StandardError
        Failure(:conversion_error)
      end
    end.format('%n realtime %rs total CPU %ts').gsub(/[()]/, '')
    logger.info 'document found, now generating document solr'
    # benchmark how long it takes to convert the object to a Solr document
    to_solr_stats = Benchmark.measure('to_solr') do
      indexer = Indexer.for(obj, cocina: cocina)
      solr_doc = indexer.to_solr
      logger.info 'solr doc created'

      solr.add(solr_doc, add_attributes: add_attributes)
    end.format('%n realtime %rs total CPU %ts').gsub(/[()]/, '')

    logger.info "successfully updated index for #{pid} (metrics: #{load_stats}; #{to_solr_stats})"

    solr_doc
  end

  def solr
    ActiveFedora.solr.conn
  end
end
