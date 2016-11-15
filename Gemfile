source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'activemodel', '~> 5.0.0'

# Use Puma as the app server
gem 'puma', '~> 3.0'

gem 'config'
gem 'honeybadger', '~> 2.0'
gem 'rack-timeout'
gem 'faraday'

gem 'active-fedora'
gem 'dor-services', '~> 5.14'
gem 'rsolr', '~> 2.0.0.pre'
gem 'okcomputer' # for monitoring

group :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', '~> 3.0'
end
