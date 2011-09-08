require "devise_crowd/version"
require 'devise'
require 'simple_crowd'

require 'devise_crowd/logger'
require 'devise_crowd/config'
require 'devise_crowd/schema'

Devise.add_module(:crowd_authenticatable,
  :strategy => true,
  :model => 'devise_crowd/model'
)
