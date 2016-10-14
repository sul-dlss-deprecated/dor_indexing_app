source 'https://rubygems.org'

gem 'config'
gem 'rails', '4.2.7.1'
gem 'activemodel', '4.2.7.1'
gem 'honeybadger', '~> 2.0'
gem 'rack-timeout'

gem 'dor-services', '>= 5.11.1', '< 6'
gem 'is_it_working-cbeer'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
end

group :production do
  gem 'newrelic_rpm'
end

group :test do
  gem 'coveralls', require: false
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', '~> 3.0'
end
