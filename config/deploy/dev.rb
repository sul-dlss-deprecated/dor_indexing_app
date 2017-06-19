server 'dor-indexing-app-dev.stanford.edu', user: 'dor_indexer', roles: %w{web app}

set :bundle_without, %w(test development deployment).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
