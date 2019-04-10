class DorController < ApplicationController
  def reindex
    @solr_doc = Dor::IndexingService.reindex_pid params[:pid], logger: Dor::IndexingService.generate_index_logger { request.uuid }, add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i }
    Dor::SearchService.solr.commit unless params[:commitWithin] # reindex_pid doesn't commit, but callers of this method may expect the update to be committed immediately
    render status: 200, plain: "Successfully updated index for #{params[:pid]}"
  rescue ActiveFedora::ObjectNotFoundError # => e
    render status: 404, plain: 'Object does not exist in Fedora.'
  end

  def delete_from_index
    Dor::SearchService.solr.delete_by_id(params[:pid], commitWithin: params.fetch(:commitWithin, 1000).to_i)
    Dor::SearchService.solr.commit unless params[:commitWithin]
    render plain: params[:pid]
  end

  def queue_size
    render status: 200, json: { value: QueueStatus.all.queue_size }
  end
end
