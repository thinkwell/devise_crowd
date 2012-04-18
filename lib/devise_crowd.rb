require "devise_crowd/version"
require 'devise'
require 'simple_crowd'

require 'devise_crowd/helpers'
require 'devise_crowd/cookie'
require 'devise_crowd/logger'
require 'devise_crowd/config'
require 'devise_crowd/schema'
require 'devise_crowd/railtie' if defined?(Rails)

Devise.add_module(:crowd_token_authenticatable,
  :strategy => true,
  :model => 'devise_crowd/models/token_authenticatable'
)

Devise.add_module(:crowd_credentials_authenticatable,
  :strategy => true,
  :model => 'devise_crowd/models/credentials_authenticatable',
  :route => :session
)

I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")
