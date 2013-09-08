require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require 'rack/test'
require 'goliath/test_helper'
require 'evented-spec'

Goliath.env = :test

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Goliath::TestHelper
end
