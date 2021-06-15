# frozen_string_literal: true

class FallbackIndexer
  include Rubydora::FedoraUrlHelpers
  # This indexer is used when dor-services-app is unable to produce a cocina representation of the object
  FALLBACK_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    WorkflowsIndexer,
    Fedora3LabelIndexer
  )

  def initialize(id:)
    @id = id
  end

  attr_reader :id

  def to_solr
    FALLBACK_INDEXER.new(id: id, resource: fetch_object).to_solr
  end

  def fetch_object
    repo.find(id)
  end

  def repo
    @repo ||= Rubydora.connect(url: Settings.fedora_url,
                               ssl_client_cert: client_cert,
                               ssl_client_key: client_key,
                               ssl_cert_store: RestClient::Request.default_ssl_cert_store)
  end

  def client_cert
    OpenSSL::X509::Certificate.new(File.read(Settings.ssl.cert_file)) if Settings.ssl.cert_file
  end

  def client_key
    OpenSSL::PKey.read(File.read(Settings.ssl.key_file)) if Settings.ssl.key_file
  end
end
