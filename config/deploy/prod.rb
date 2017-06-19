server 'dor-indexing-app-prod-a.stanford.edu', user: 'dor_indexer', roles: %w{web app}
server 'dor-indexing-app-prod-b.stanford.edu', user: 'dor_indexer', roles: %w{web app}
server 'dor-indexing-app-prod-c.stanford.edu', user: 'dor_indexer', roles: %w{web app}

set :rails_env, 'production'
set :bundle_without, %w(test development deployment).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
