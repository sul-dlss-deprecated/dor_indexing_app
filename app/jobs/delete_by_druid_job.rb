# frozen_string_literal: true

# Deletes an index entry given a druid
class DeleteByDruidJob
  include Sneakers::Worker

  # This worker will connect to "dor.deleting-by-druid" queue
  # env is set to nil since by default the actual queue name would be
  # "dor.deleting-by-druid_development"
  from_queue 'dor.deleting-by-druid', env: nil

  def work(msg)
    druid = druid_from_message(msg)
    Indexer.delete(solr:, identifier: druid)

    ack!
  end

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def druid_from_message(str)
    JSON.parse(str).fetch('druid')
  end
end
