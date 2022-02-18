# frozen_string_literal: true

server 'dor-indexing-app-prod-a.stanford.edu', user: 'dor_indexer', roles: %w[web app rolling_indexer]
server 'dor-indexing-app-prod-b.stanford.edu', user: 'dor_indexer', roles: %w[web app]
server 'dor-indexing-app-prod-c.stanford.edu', user: 'dor_indexer', roles: %w[web app]

Capistrano::OneTimeKey.generate_one_time_key!
