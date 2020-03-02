# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2.3'

# Use Puma as the app server
gem 'puma', '~> 3.0'

gem 'erubis'

gem 'config'
gem 'faraday'
gem 'honeybadger', '~> 4.5'
# iso-639 0.3.0 isn't compatible with ruby 2.5.  This declaration can be dropped when we upgrade to ruby 2.6
# see https://github.com/alphabetum/iso-639/issues/12
gem 'iso-639', '~> 0.2.10'
gem 'rack-timeout', '~> 0.5.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'dor-services', '~> 9.0'
gem 'dor-services-client', '~> 4.11'
gem 'dor-workflow-client', '~> 3.20'
gem 'okcomputer' # for monitoring
gem 'rsolr', '~> 2.0'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'byebug'
  gem 'coveralls', require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'simplecov', '~> 0.17.1', require: false # 0.18 breaks reporting to coveralls `undefined method `coverage' for #<SimpleCov::SourceFile:0x0000561b4563cd18>`
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', '~> 0.74.0'
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
  gem 'dlss-capistrano', '~> 3.0'
end
