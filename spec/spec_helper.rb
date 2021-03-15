require_relative '../app.rb'

require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'selenium/webdriver'
require 'pry'

ENV['RACK_ENV'] = 'test'

Capybara.app = LoginGov::FakeVendorServer
Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium

module UrlHelpers
  def base_url
    server = Capybara.current_session.server
    "http://#{server.host}:#{server.port}"
  end
end
  
RSpec.configure do |config|
  config.include Capybara::DSL
  config.include UrlHelpers
 end
