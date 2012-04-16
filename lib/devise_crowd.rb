require "devise_crowd/version"
require 'devise'
require 'simple_crowd'

require 'devise_crowd/logger'
require 'devise_crowd/config'
require 'devise_crowd/schema'
require 'devise_crowd/railtie' if defined?(Rails)

Devise.add_module(:crowd_token_authenticatable,
  :strategy => true,
  :model => 'devise_crowd/models/token_authenticatable'
)

I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")
