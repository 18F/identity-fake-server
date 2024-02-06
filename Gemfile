source 'https://rubygems.org'

gem 'sinatra', '~> 4.0.0'
gem 'prometheus-client'
gem 'puma'
gem 'newrelic_rpm'
gem 'nokogiri', '~> 1.16'
gem 'rack', '~> 3.0.0'
gem 'rake', '~> 13.0.0'

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'pry-byebug'
  gem 'rackup'
  gem 'rack-test', '>= 2.0.0'
  gem 'rspec'
end

group :development, :test do
  gem 'aamva', github: '18F/identity-aamva-api-client-gem', tag: 'v4.2.0'
  gem 'identity-doc-auth', github: '18F/identity-doc-auth', tag: 'v0.13.0'
  gem 'lexisnexis', github: '18F/identity-lexisnexis-api-client-gem', tag: 'v3.2.1'
  gem 'proofer', github: '18F/identity-proofer-gem', ref: 'v2.8.0'
end
