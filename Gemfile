# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'bunny', '~> 2.19' # for rabbitmq
gem 'committee' # Validates HTTP requests/responses per OpenAPI specification
gem 'config'
gem 'daemons' # for rolling indexer
gem 'dry-monads', '~> 1.3'
gem 'erubis'
gem 'faraday'
gem 'honeybadger', '~> 4.5'
# ISO-639-1 and -2
gem 'iso-639', '~> 0.3.5'
# ISO-639-3
gem 'language_list'
gem 'marc-vocab', '~> 0.3.0'
gem 'okcomputer' # for monitoring
gem 'puma', '~> 5.3' # app server
gem 'rack-timeout', '~> 0.5.1'
gem 'rails', '~> 7.0.0'
gem 'rsolr', '~> 2.0'
gem 'sneakers', '~> 2.11'
gem 'solrizer'

# DLSS gems
gem 'dor-services-client', '~> 12.0'
gem 'dor-workflow-client', '~> 5.0'
gem 'parse_date'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'byebug'
  gem 'rspec', '~> 3.0' # need this to use cocina-models factories
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 5.0'
  gem 'simplecov'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', require: false
end
