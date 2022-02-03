# frozen_string_literal: true

# Reindexes an object
class ReindexJob
  include Sneakers::Worker
  # This worker will connect to "dor.indexing-with-model" queue
  # env is set to nil since by default the actual queue name would be
  # "dor.indexing-with-model_development"
  from_queue 'dor.indexing-with-model', env: nil

  def work(msg)
    model = build_cocina_model_from_json_str(msg)
    # Since we don't have the metadata (namely created_at) in the message,
    # we need another API call. :(
    indexer = Indexer.new(solr: solr)
    indexer.reindex_pid model.externalIdentifier, add_attributes: { commitWithin: 1000 }
    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def build_cocina_model_from_json_str(str)
    json = JSON.parse(str)
    Cocina::Models.build(json.fetch('model'))
  end
end
