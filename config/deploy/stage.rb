set :deploy_host, 'dor-indexing-app-stage'
server_extensions = ['a', 'b']
server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}-#{extension}.stanford.edu", user: fetch(:user), roles: %w{web app}
end

set :rails_env, 'production'
set :bundle_without, %w(test development).join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
