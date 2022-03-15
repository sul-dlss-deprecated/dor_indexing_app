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
    pid = cocina_with_metadata.value!.first.externalIdentifier
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

    metadata = Dor::Services::Client::ObjectMetadata.new(updated_at: json.fetch('modified_at'),
                                                         created_at: json.fetch('created_at'))
    Success([model, metadata])
  end
end
