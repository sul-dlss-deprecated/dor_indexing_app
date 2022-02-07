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
    indexer = Indexer.new(solr: solr, pid: druid)
    cocina_with_metadata = indexer.fetch_model_with_metadata
    indexer.reindex_pid(
      add_attributes: { commitWithin: 1000 },
      cocina_with_metadata: cocina_with_metadata
    )
    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def druid_from_message(str)
    JSON.parse(str).fetch('druid')
  end
end
