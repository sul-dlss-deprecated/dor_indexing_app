# frozen_string_literal: true

set :application, 'dor_indexing_app'

set :repo_url, 'https://github.com/sul-dlss/dor_indexing_app'

# prompt for branch or tag, default to current working branch from which deployment occurs
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :deploy_to, '/opt/app/dor_indexer/dor_indexing_app'

set :linked_dirs, %w[log config/settings tmp/pids tmp/cache tmp/sockets vendor/bundle]
set :linked_files, %w[config/secrets.yml config/honeybadger.yml config/newrelic.yml]

set :rails_env, 'production'
set :bundle_without, %w[test development deployment].join(' ')

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# Manage sneakers via systemd (from dlss-capistrano gem)
set :sneakers_systemd_use_hooks, true

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'

# Set up RabbitMQ (see README)
namespace :rabbitmq do
  task :setup do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          rake 'rabbitmq:setup'
        end
      end
    end
  end
end

before 'sneakers_systemd:start', 'rabbitmq:setup'
