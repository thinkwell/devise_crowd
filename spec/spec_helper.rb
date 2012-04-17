ENV["RAILS_ENV"] = "test"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require 'rr'
require 'ostruct'
require 'action_controller'
require 'mongoid'
require 'devise'
require 'devise_crowd'
require 'simple_crowd/mock_client'

Devise.setup do |config|
  config.apply_schema = false
  require 'devise/orm/mongoid'
  config.crowd_enabled = true
  config.case_insensitive_keys = [ ]
  config.use_salt_as_remember_token = true
  config.reset_password_within = 2.hours
end
require 'mock/user'
require 'rails_app/config/environment'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr

  config.before :each do
    @mock_crowd_client = SimpleCrowd::MockClient.new
    stub(SimpleCrowd::Client).new {@mock_crowd_client}
    SimpleCrowd::MockClient.reset
  end
end

# Create a very simple Warden::Manager mock that contains an empty session
# hash.  The DeviseCrowd strategy saves session data directly to the session
# hash which we stub here.
def warden_manager
  mock_warden = OpenStruct.new
  mock_warden.session = mock_warden.raw_session = {}
  mock_warden.warden_cookies = {}
  mock_warden
end
