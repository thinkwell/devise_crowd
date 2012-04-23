require 'devise_crowd/session'
require 'devise_crowd/hooks'

module Devise::Models
  module CrowdCommon
    extend ActiveSupport::Concern

    included do |base|
      base.send :define_model_callbacks, :create_from_crowd
      base.send :define_model_callbacks, :sync_from_crowd
    end

    attr_accessor :crowd_client, :crowd_record

    def after_crowd_authentication
    end

    def needs_crowd_auth?(last_auth)
      last_auth && last_auth <= self.class.crowd_auth_every.ago
    end

    def next_crowd_auth(last_auth)
      return Time.now unless last_auth
      last_auth + self.class.crowd_auth_every
    end

    def crowd_client
      @crowd_client ||= self.class.crowd_client
    end

    # Create a new local record from a crowd record.
    # Subclasses should override `do_create_from_crowd` instead of this method.
    def create_from_crowd
      run_callbacks(:create_from_crowd) do
        result = do_create_from_crowd
        result == false ? false : true
      end
    end

    def do_create_from_crowd
      sync_from_crowd
    end
    private :do_create_from_crowd

    # Synchronize from the crowd record to the local record.
    # Subclasses should override `do_sync_from_crowd` instead of this method.
    def sync_from_crowd
      run_callbacks(:sync_from_crowd) do
        result = do_sync_from_crowd
        result == false ? false : true
      end
    end

    def do_sync_from_crowd
    end
    private :do_sync_from_crowd


    module ClassMethods
      Devise::Models.config(self, :crowd_enabled, :crowd_service_url, :crowd_app_name, :crowd_app_password, :crowd_token_key, :crowd_username_key, :crowd_auth_every, :crowd_allow_forgery_protection, :crowd_auto_register)

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

      def crowd_username_key_with_default
        key = crowd_username_key_without_default
        unless key
          key = (authentication_keys.is_a?(Hash) ? authentication_keys.keys : authentication_keys).first
        end
        key
      end
      alias_method_chain :crowd_username_key, :default

      def find_for_crowd_username(username)
        find_for_authentication({self.crowd_username_key => username})
      end

    end
  end
end
