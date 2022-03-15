# frozen_string_literal: true

# Reindexes an object given a druid
class ReindexByDruidJob
  include Sneakers::Worker
  # This worker will connect to "dor.indexing-by-druid" queue
  # env is set to nil since by default the actual queue name would be
  # "dor.indexing-by-druid_development"
  from_queue 'dor.indexing-by-druid', env: nil

  def work(msg)
    druid = druid_from_message(msg)
    # Since we don't have the metadata (namely created_at) in the message,
    # we need another API call. :(
    indexer = Indexer.new(solr: solr, identifier: druid)
    cocina_with_metadata = indexer.fetch_model_with_metadata
    indexer.reindex(
      add_attributes: { commitWithin: 1000 },
      cocina_with_metadata: cocina_with_metadata
    )
    ack!
  rescue Dor::Services::Client::NotFoundResponse, Rubydora::RecordNotFound
    Honeybadger.notify('Cannot reindex since not found. This may be because applications (e.g., PresCat) are creating workflow steps for deleted objects.',
                       { druid: druid_from_message(msg) })
    Rails.logger.info("Cannot reindex #{druid_from_message(msg)} by druid since it is not found.")
    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def druid_from_message(str)
    JSON.parse(str).fetch('druid')
  end
end
