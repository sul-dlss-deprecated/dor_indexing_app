# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'bunny', '~> 2.19' # for rabbitmq
gem 'committee' # Validates HTTP requests/responses per OpenAPI specification
gem 'config'
gem 'faraday'
gem 'honeybadger'
gem 'okcomputer' # for monitoring
gem 'puma', '~> 5.3' # app server
gem 'rack-timeout', '~> 0.5.1'
gem 'rails', '~> 7.0.0'
gem 'rsolr', '~> 2.0'
gem 'sneakers', '~> 2.11'

# DLSS gems
gem 'dor_indexing', '~> 1.2'
gem 'dor-services-client', '~> 14.1'
gem 'dor-workflow-client', '~> 7.0'

group :development, :test do
  gem 'byebug'
  gem 'rspec', '~> 3.0' # need this to use cocina-models factories
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 5.0'
  gem 'simplecov'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :deployment do
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'dlss-capistrano', require: false
end
