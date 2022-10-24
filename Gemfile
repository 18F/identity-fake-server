source 'https://rubygems.org'

gem 'sinatra', '~> 2.2.2'
gem 'nokogiri', '~> 1.13.9'
gem 'rake', '~> 13.0.0'
gem 'puma', '~> 5.6.5'

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'pry-byebug'
  gem 'rack-test', '>= 2.0.0'
  gem 'rspec'
end

group :development, :test do
  gem 'aamva', github: '18F/identity-aamva-api-client-gem', tag: 'v4.2.0'
  gem 'identity-doc-auth', github: '18F/identity-doc-auth', tag: 'v0.13.0'
  gem 'lexisnexis', github: '18F/identity-lexisnexis-api-client-gem', tag: 'v3.2.1'
  gem 'proofer', github: '18F/identity-proofer-gem', tag: 'v2.8.0'
end
