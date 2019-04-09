class DorController < ApplicationController
  def reindex
    @solr_doc = Dor::IndexingService.reindex_pid params[:pid], logger: generate_index_logger(request.uuid), add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i }
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

  private

  ##
  # Returns a Logger instance for recording info about indexing attempts
  # @param [String] entry_id an extra identifier for the log entry.
  def generate_index_logger(entry_id)
    index_logger = Logger.new(Settings.INDEXER.LOG, Settings.INDEXER.LOG_ROTATION_INTERVAL)
    index_logger.formatter = proc do |_severity, datetime, _progname, msg|
      date_format_str = Settings.DATE_FORMAT_STR
      "[#{entry_id}] [#{datetime.utc.strftime(date_format_str)}] #{msg}\n"
    end
    index_logger
  end
end
