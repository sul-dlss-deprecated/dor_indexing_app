set :application, 'dor_indexing_app'

set :repo_url, 'https://github.com/sul-dlss/dor_indexing_app'

# prompt for branch or tag, default to current working branch from which deployment occurs
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
ask :user, proc { `whoami`.chomp }.call
set :home_directory, "/opt/app/#{fetch(:user)}"

set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"

set :linked_dirs, %w(log config/settings tmp/pids tmp/cache tmp/sockets vendor/bundle)

before 'deploy:publishing', 'squash:write_revision'
