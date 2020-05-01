# frozen_string_literal: true

Dor.configure do
  ssl do
    cert_file Settings.ssl.cert_file
    key_file Settings.ssl.key_file
    key_pass Settings.ssl.key_pass
  end

  fedora do
    url Settings.fedora_url
  end

  solr do
    url Settings.solrizer_url
  end
end
