class DorController < ApplicationController
  def reindex
    @solr_doc = Dor::IndexingService.reindex_pid params[:pid], logger: Dor::IndexingService.generate_index_logger { request.uuid }, add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i }
    Dor::SearchService.solr.commit unless params[:commitWithin] # reindex_pid doesn't commit, but callers of this method may expect the update to be committed immediately
    render status: 200, text: "Successfully updated index for #{params[:pid]}"
  rescue ActiveFedora::ObjectNotFoundError # => e
    render status: 404, text: 'Object does not exist in Fedora.'
  end
end
