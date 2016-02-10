server 'dor-indexing-app-stage.stanford.edu', user: fetch(:user), roles: %w(web db app)

set :rails_env, 'staging'
set :bundle_without, %w(test development).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
