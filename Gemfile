# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2.3'

# Use Puma as the app server
gem 'puma', '~> 3.0'

gem 'erubis'

gem 'config'
gem 'faraday'
gem 'honeybadger', '~> 3.0'
gem 'rack-timeout', '~> 0.5.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'dor-services', '~> 8.0'
gem 'okcomputer' # for monitoring
gem 'rsolr', '~> 2.0'

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'coveralls', require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'simplecov', require: false
end

group :development do
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
