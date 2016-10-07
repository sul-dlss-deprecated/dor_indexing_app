source 'https://rubygems.org'

gem 'config'
gem 'rails', '4.2.7.1'
gem 'squash_rails'
gem 'squash_ruby'
gem 'rack-timeout'

gem 'dor-services', '>= 5.11.1', '< 6'
gem 'is_it_working-cbeer'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
end

group :test do
  gem 'coveralls', require: false
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano', '~> 3.0'
end
