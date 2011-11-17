ENV["RAILS_ENV"] = "test"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require 'rr'
require 'action_controller'
require 'mongoid'
require 'devise'
require 'devise_crowd'
Devise.setup do |config|
  require 'devise/orm/mongoid'
  config.crowd_enabled = true
end
require 'mock/user'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
end
