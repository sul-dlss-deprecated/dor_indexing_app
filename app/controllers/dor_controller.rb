class DorController < ApplicationController
  def reindex
    @solr_doc = Dor::IndexingService.reindex_pid params[:pid], Dor::IndexingService.generate_index_logger { request.uuid }
    Dor::SearchService.solr.commit # reindex_pid doesn't commit, but callers of this method may expect the update to be committed immediately
    render status: 200, text: "Successfully updated index for #{params[:pid]}"
  rescue ActiveFedora::ObjectNotFoundError # => e
    render status: 404, text: 'Object does not exist in Fedora.'
  end
end
