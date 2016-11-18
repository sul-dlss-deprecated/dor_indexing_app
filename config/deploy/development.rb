server 'dor-indexing-app-dev.stanford.edu', user: fetch(:user), roles: %w{web app}

set :bundle_without, %w(test development deployment).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
