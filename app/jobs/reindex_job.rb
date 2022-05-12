# frozen_string_literal: true

# Reindexes an object
class ReindexJob
  include Sneakers::Worker

  # This worker will connect to "dor.indexing-with-model" queue
  # env is set to nil since by default the actual queue name would be
  # "dor.indexing-with-model_development"
  from_queue 'dor.indexing-with-model', env: nil

  def work(msg)
    Indexer.reindex(solr: solr, cocina_with_metadata: build_cocina_model(msg))
    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def build_cocina_model(str)
    json = JSON.parse(str)
    model = Cocina::Models.build(json.fetch('model'))
    # Lock is required, but we don't know what it is. Since not updating, that is OK.
    Cocina::Models.with_metadata(model, 'unknown_lock', created: DateTime.parse(json.fetch('created_at')), modified: DateTime.parse(json.fetch('modified_at')))
  end
end
