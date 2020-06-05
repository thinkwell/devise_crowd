require 'devise_crowd/session'
require 'devise_crowd/hooks'

module Devise::Models
  module CrowdCommon
    extend ActiveSupport::Concern

    included do |base|
      base.send :define_model_callbacks, :create_from_crowd
      base.send :define_model_callbacks, :sync_from_crowd
      base.send :define_model_callbacks, :create_crowd_record
      base.send :define_model_callbacks, :sync_to_crowd

      base.send :after_create, :create_crowd_record, :if => [:crowd_enabled?, :adding_crowd_records?], :unless => :has_crowd_record?
      base.send :after_update, :sync_to_crowd, :if => [:crowd_enabled?, :updating_crowd_records?, :has_crowd_record?]
    end

    attr_accessor :crowd_client, :crowd_record, :crowd_password
    private :crowd_password

    def after_crowd_authentication
    end

    def crowd_client
      @crowd_client ||= self.class.crowd_client
    end

    def crowd_enabled?
      self.class.crowd_enabled?
    end

    def adding_crowd_records?
      self.class.add_crowd_records
    end

    def updating_crowd_records?
      self.class.update_crowd_records
    end

    def has_crowd_record?
      !!self.crowd_record
    end

    def needs_crowd_auth?(last_auth)
      last_auth && last_auth <= self.class.crowd_auth_every.ago
    end

    def next_crowd_auth(last_auth)
      return Time.now unless last_auth
      last_auth + self.class.crowd_auth_every
    end

    def crowd_record
      return nil unless crowd_enabled?
      if @crowd_record.nil?
        @crowd_record = false
        username = self.send(:"#{self.class.crowd_username_key}")
        record = DeviseCrowd.crowd_fetch {crowd_client.find_user_by_name(username)} if username
        @crowd_record = record if record
      end
      @crowd_record == false ? nil : @crowd_record
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
      return if @crowd_syncing
      @crowd_syncing = true
      is_new = new_record?
      begin
        run_callbacks(:sync_from_crowd) do
          DeviseCrowd::Logger.send "Synchronizing from crowd record."
          do_sync_from_crowd
          if changed?
            if save
              DeviseCrowd::Logger.send "#{is_new ? 'Created new local user' : 'Synchronized'} from crowd record."
            else
              DeviseCrowd::Logger.send "Could not create local user from crowd record (#{errors.messages.inspect})"
            end
          end
          true
        end
      ensure
        @crowd_syncing = false
      end
    end

    def do_sync_from_crowd
    end
    private :do_sync_from_crowd

    def create_crowd_record
      username = self.send(:"#{self.class.crowd_username_key}")
      return unless username
      run_callbacks(:create_crowd_record) do
        self.crowd_record = SimpleCrowd::User.new({:username => username})
        result = do_create_crowd_record
        result == false ? false : true
      end
    end

    def do_create_crowd_record
      sync_to_crowd
    end
    private :do_create_crowd_record

    # Synchronize from the local record to the Crowd record.
    # Subclasses should override `do_sync_to_crowd` instead of this method.
    def sync_to_crowd
      return if @crowd_syncing || !crowd_record
      @crowd_syncing = true
      is_new = !crowd_record.id
      begin
        run_callbacks(:sync_to_crowd) do
          DeviseCrowd::Logger.send "Synchronizing to crowd record."
          do_sync_to_crowd
          if is_new || crowd_record.dirty? || crowd_password
            if is_new
              crowd_client.add_user crowd_record, crowd_password
            else
              crowd_client.update_user crowd_record if crowd_record.dirty?
              crowd_client.update_user_credential crowd_record.username, crowd_password if crowd_password
            end
            DeviseCrowd::Logger.send "#{is_new ? 'Created new' : 'Synchronized to'} crowd record."
          end
          true
        end
      ensure
        @crowd_syncing = false
      end
    end

    def do_sync_to_crowd
    end
    private :do_sync_to_crowd


    module CrowdUsernameKeyWithDefault
      def default
        key = super
        unless key
          key = (authentication_keys.is_a?(Hash) ? authentication_keys.keys : authentication_keys).first
        end
        key
      end
    end

    module ClassMethods
      prepend CrowdUsernameKeyWithDefault

      Devise::Models.config(self, :crowd_enabled, :crowd_service_url, :crowd_app_name, :crowd_app_password, :crowd_token_key, :crowd_username_key, :crowd_auth_every, :crowd_allow_forgery_protection, :crowd_auto_register, :add_crowd_records, :update_crowd_records)

      def crowd_client
        SimpleCrowd::Client.new({
          :service_url => self.crowd_service_url,
          :app_name => self.crowd_app_name,
          :app_password => self.crowd_app_password,
          :cache_store => Rails.cache,
        })
      end

      def crowd_enabled?(strategy=nil)
        if crowd_enabled.is_a?(Array)
          strategy ? crowd_enabled.include?(strategy) : !crowd_enabled.empty?
        else
          crowd_enabled
        end
      end

      def find_for_crowd_username(username)
        find_for_authentication({self.crowd_username_key => username})
      end

      def crowd_resource_class
        self
      end
    end
  end
end
