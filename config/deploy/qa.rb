# frozen_string_literal: true

server 'dor-indexing-app-qa-a.stanford.edu', user: 'dor_indexer', roles: %w[web app rolling_indexer]
server 'dor-indexing-app-qa-b.stanford.edu', user: 'dor_indexer', roles: %w[web app]

Capistrano::OneTimeKey.generate_one_time_key!
