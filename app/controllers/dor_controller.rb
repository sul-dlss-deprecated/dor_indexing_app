# frozen_string_literal: true

# Main controller of application
class DorController < ApplicationController
  def reindex
    indexer = Indexer.new(solr: solr)
    @solr_doc = indexer.reindex_pid params[:pid], add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i }
    indexer.commit unless params[:commitWithin] # reindex_pid doesn't commit, but callers of this method may expect the update to be committed immediately
    render status: :ok, plain: "Successfully updated index for #{params[:pid]}"
  rescue Dor::Services::Client::NotFoundResponse, Rubydora::RecordNotFound
    render status: :not_found, plain: 'Object does not exist in the repository'
  end

  def delete_from_index
    solr.delete_by_id(params[:pid], commitWithin: params.fetch(:commitWithin, 1000).to_i)
    solr.commit unless params[:commitWithin]
    render plain: params[:pid]
  end

  def queue_size
    render status: :ok, json: { value: QueueStatus.all.queue_size }
  end

  private

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end
end
