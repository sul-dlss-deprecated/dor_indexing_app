server 'dor-indexing-app-stage-a.stanford.edu', user: fetch(:user), roles: %w{web app}
server 'dor-indexing-app-stage-b.stanford.edu', user: fetch(:user), roles: %w{web app}

set :rails_env, 'production'
set :bundle_without, %w(test development deployment).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
