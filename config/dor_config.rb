# frozen_string_literal: true

Dor.configure do
  ssl do
    cert_file Settings.SSL.CERT_FILE
    key_file Settings.SSL.KEY_FILE
    key_pass Settings.SSL.KEY_PASS
  end

  fedora do
    url Settings.FEDORA_URL
  end

  solr do
    url Settings.SOLRIZER_URL
  end

  workflow do
    url Settings.WORKFLOW_URL
    logfile Settings.WORKFLOW.LOGFILE
    shift_age Settings.WORKFLOW.SHIFT_AGE
  end

  dor_services do
    url Settings.DOR_SERVICES_URL
  end

  suri do
    mint_ids     Settings.SURI.MINT_IDS
    id_namespace Settings.SURI.ID_NAMESPACE
    url          Settings.SURI.URL
    user         Settings.SURI.USER
    pass         Settings.SURI.PASS
  end

  metadata do
    catalog.url Settings.METADATA.CATALOG_URL
  end

  stomp do
    client_id Settings.STOMP_CLIENT_ID
  end

  content do
    content_user     Settings.CONTENT.USER
    content_base_dir Settings.CONTENT.BASE_DIR
    content_server   Settings.CONTENT.SERVER_HOST
    sdr_server       Settings.CONTENT.SDR_SERVER_URL
    sdr_user         Settings.CONTENT.SDR_USER
    sdr_pass         Settings.CONTENT.SDR_PASSWORD
  end

  status do
    indexer_url Settings.STATUS_INDEXER_URL
  end

  stacks do
    document_cache_host         Settings.STACKS.DOCUMENT_CACHE_HOST
    document_cache_user         Settings.STACKS.DOCUMENT_CACHE_USER
    local_workspace_root        Settings.STACKS.LOCAL_WORKSPACE_ROOT
    host                        Settings.STACKS.HOST
    user                        Settings.STACKS.USER
  end

  indexing_svc do
    log Settings.INDEXER.LOG
    log_date_format_str Settings.DATE_FORMAT_STR
    log_rotation_interval Settings.INDEXER.LOG_ROTATION_INTERVAL
  end
end
