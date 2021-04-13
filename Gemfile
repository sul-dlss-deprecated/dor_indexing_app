# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'committee' # Validates HTTP requests/responses per OpenAPI specification
gem 'config'
gem 'dry-monads', '~> 1.3'
gem 'erubis'
gem 'faraday'
gem 'honeybadger', '~> 4.5'
# ISO-639-1 and -2
gem 'iso-639', '~> 0.3.5'
# ISO-639-3
gem 'language_list'
gem 'okcomputer' # for monitoring
gem 'puma', '~> 3.0' # app server
gem 'rack-timeout', '~> 0.5.1'
gem 'rails', '~> 5.2.3'
gem 'rsolr', '~> 2.0'

# DLSS gems
gem 'dor-rights-auth', '~>1.5' # 1.5 or better is needed to ensure we index controlled digital lending rights object correctly
gem 'dor-services', '~> 9.0', '>= 9.2.1' # must be 9.2.1 to get fix from https://github.com/sul-dlss/dor-services/pull/695
gem 'dor-services-client', '~> 6.30'
gem 'dor-workflow-client', '~> 3.20'
gem 'parse_date'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'simplecov'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', '~> 0.90'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', '~> 3.11'
end
