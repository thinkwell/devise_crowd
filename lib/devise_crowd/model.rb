require 'devise_crowd/session'
require 'devise_crowd/strategy'
require 'devise_crowd/hooks'

module Devise::Models
  module CrowdAuthenticatable
    extend ActiveSupport::Concern

    def after_crowd_authentication
    end

    def needs_crowd_auth?(last_auth)
      last_auth && last_auth <= self.class.crowd_auth_every.ago
    end

    module ClassMethods
      Devise::Models.config(self, :crowd_enabled, :crowd_service_url, :crowd_app_name, :crowd_app_password, :crowd_auth_every, :crowd_cookie_tokenkey, :crowd_param_tokenkey, :crowd_username_field, :crowd_allow_forgery_protection)

      def crowd_client
        SimpleCrowd::Client.new({
          :service_url => self.crowd_service_url,
          :app_name => self.crowd_app_name,
          :app_password => self.crowd_app_password,
          :cache_store => Rails.cache,
        })
      end

      def crowd_enabled?(strategy)
        crowd_enabled.is_a?(Array) ?
          crowd_enabled.include?(strategy) : crowd_enabled
      end

      # We assume this method already gets the sanitized values from the
      # CrowdAuthenticatable strategy. If you are using this method on
      # your own, be sure to sanitize the conditions hash to only include
      # the proper fields.
      def find_for_crowd_authentication(conditions)
        find_for_authentication(conditions)
      end

    end
  end
end
