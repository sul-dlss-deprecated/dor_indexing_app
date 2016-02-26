server "dor-indexing-app-legacy-prod.stanford.edu", user: fetch(:user), roles: %w{web app}

set :rails_env, 'production'
set :bundle_without, %w(test development).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
