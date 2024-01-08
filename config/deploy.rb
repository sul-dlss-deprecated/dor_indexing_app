# frozen_string_literal: true

set :application, 'dor_indexing_app'

set :repo_url, 'https://github.com/sul-dlss/dor_indexing_app'

# prompt for branch or tag, default to current working branch from which deployment occurs
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :deploy_to, '/opt/app/dor_indexer/dor_indexing_app'

set :linked_dirs, %w[log config/settings tmp/pids tmp/cache tmp/sockets vendor/bundle]
set :linked_files, %w[config/honeybadger.yml]

set :rails_env, 'production'
set :bundle_without, %w[test development deployment].join(' ')

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# Manage sneakers via systemd (from dlss-capistrano gem)
set :sneakers_systemd_use_hooks, true

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'

# Tasks for managing the rolling indexer
namespace :rolling_indexer do # rubocop:disable Metrics/BlockLength
  desc 'Stop rolling indexer'
  task :stop do
    on roles(:rolling_indexer) do
      sudo :systemctl, 'stop', 'rolling-index'
    end
  end

  desc 'Start rolling indexer'
  task :start do
    on roles(:rolling_indexer) do
      sudo :systemctl, 'start', 'rolling-index'
      sudo :systemctl, 'status', 'rolling-index'
    end
  end

  desc 'Restart rolling indexer'
  task :restart do
    on roles(:rolling_indexer) do
      sudo :systemctl, 'restart', 'rolling-index', raise_on_non_zero_exit: false
      sudo :systemctl, 'status', 'rolling-index'
    end
  end

  desc 'Print status of rolling indexer'
  task :status do
    on roles(:rolling_indexer) do
      sudo :systemctl, 'status', 'rolling-index'
    end
  end
end

after 'deploy:starting', 'rolling_indexer:stop'
after 'deploy:published', 'rolling_indexer:start'
after 'deploy:failed', 'rolling_indexer:restart'
