source 'https://rubygems.org'

gem 'config'
gem 'rails', '~> 4.2.5'

gem 'dor-services', '~> 5.0', :git => 'https://github.com/sul-dlss/dor-services.git', :branch => 'indexing-service'

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
