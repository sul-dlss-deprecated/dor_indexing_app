# frozen_string_literal: true

# Reindexes an object
class ReindexJob
  include Sneakers::Worker
  include Dry::Monads[:result]

  # This worker will connect to "dor.indexing-with-model" queue
  # env is set to nil since by default the actual queue name would be
  # "dor.indexing-with-model_development"
  from_queue 'dor.indexing-with-model', env: nil

  def work(msg)
    cocina_with_metadata = build_cocina_model_from_json_str(msg)
    pid = cocina_with_metadata.value!.externalIdentifier
    indexer = Indexer.new(solr: solr, identifier: pid)
    indexer.reindex(
      add_attributes: { commitWithin: 1000 },
      cocina_with_metadata: cocina_with_metadata
    )
    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def build_cocina_model_from_json_str(str)
    json = JSON.parse(str)
    model = Cocina::Models.build(json.fetch('model'))
    # Lock is required, but we don't know what it is. Since not updating, that is OK.
    model_with_metadata = Cocina::Models.with_metadata(model, 'unknown_lock', created: DateTime.parse(json.fetch('created_at')), modified: DateTime.parse(json.fetch('modified_at')))
    Success(model_with_metadata)
  end
end
