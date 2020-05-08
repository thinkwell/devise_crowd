module Devise::Strategies
  module CrowdCommon
    attr_accessor :crowd_username, :crowd_record
    attr_reader :crowd_token

    def crowd_username
      @crowd_username ||= @crowd_record && @crowd_record[:username]
    end

    def crowd_username=(username)
      @crowd_record = nil
      @crowd_username = username
    end

    def crowd_record
      if !@crowd_record && @crowd_username
        Rails.logger.debug "DEVISE CROWD : crowd_record : find_user_by_name #{@crowd_username}"
        @crowd_record = DeviseCrowd.crowd_fetch { crowd_client.find_user_by_name(@crowd_username) }
      end

      @crowd_record
    end

    def crowd_record=(record)
      @crowd_record = record
      @crowd_username = record ? record[:username] : nil
    end

    private

    def validate_crowd_username!
      # lookup resource on DB first
      if crowd_username
        resource = resource_class.find_by_username(crowd_username)
      end

      # if resource not found lookup on CROWD
      if crowd_username && !resource
        resource = resource_class.find_for_crowd_username(crowd_username)
        resource = create_from_crowd if !resource && crowd_auto_register?
      end

      if resource && validate(resource)
        return if halted?
        if crowd_allow_forgery_protection? && crowd_unverified_request?
          DeviseCrowd::Logger.send("Can't verify CSRF token authenticity.")
          fail(:crowd_unverified_request)
        else
          DeviseCrowd::Logger.send("authenticated via #{authenticatable_name}!")
          sync_from_crowd(resource) if sync_from_crowd? and update_crowd_records?
          cache_authentication if store?
          yield(resource) if block_given?
          success!(resource)
        end
      else
        DeviseCrowd::Logger.send("not authenticated via #{authenticatable_name} (no local user)!")
        return if halted?
        fail(:crowd_unknown_user)
      end
    end

    def resource_class
      mapping.to.crowd_resource_class
    end

    def warden
      env['warden']
    end

    def crowd_allow_forgery_protection?
      !!resource_class.crowd_allow_forgery_protection
    end

    def crowd_unverified_request?
      !!request.env['crowd.unverified_request']
    end

    def crowd_auto_register?
      !!resource_class.crowd_auto_register
    end

    def update_crowd_records?
      !!resource_class.update_crowd_records
    end

    def crowd_client
      @crowd_client ||= resource_class.crowd_client
    end

    def cache_authentication
      crowd_session = DeviseCrowd.session(warden, scope)
      crowd_session['crowd.last_auth'] = Time.now
      crowd_session['crowd.last_token'] = crowd_token
      crowd_session['crowd.last_username'] = crowd_username
      DeviseCrowd::Logger.send "Cached crowd authorization.  Next authorization at #{Time.now + resource_class.crowd_auth_every}."
    end

    # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
    # becomes simply :database.
    def authenticatable_name
      @authenticatable_name ||=
        ActiveSupport::Inflector.underscore(self.class.name.split("::").last).
          sub("_authenticatable", "").to_sym
    end

    def create_from_crowd
      resource = resource_class.crowd_resource_class.new({resource_class.crowd_username_key => crowd_username})
      resource.crowd_client = crowd_client
      resource.crowd_record = crowd_record
      result = resource.create_from_crowd
      return nil if result == false
      return nil unless resource.errors.empty?
      @created_record = true
      resource
    end

    def sync_from_crowd?
      return false if @created_record
      crowd_session = DeviseCrowd.session(warden, scope)
      !crowd_session['crowd.last_token'] || crowd_session['crowd.last_token'] != crowd_token
    end

    def sync_from_crowd(resource)
      return unless resource
      resource.crowd_client = crowd_client
      resource.crowd_record = crowd_record
      result = resource.sync_from_crowd
      return nil if result == false
    end
  end
end
