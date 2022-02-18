# frozen_string_literal: true

server 'dor-indexing-app-stage-a.stanford.edu', user: 'dor_indexer', roles: %w[web app]
server 'dor-indexing-app-stage-b.stanford.edu', user: 'dor_indexer', roles: %w[web app]

Capistrano::OneTimeKey.generate_one_time_key!
