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
      @crowd_record ||= @crowd_username && DeviseCrowd.crowd_fetch { crowd_client.find_user_by_name(@crowd_username) }
    end

    def crowd_record=(record)
      @crowd_record = record
      @crowd_username = record ? record[:username] : nil
    end

    private

    def validate_crowd_username!
      if crowd_username
        resource = mapping.to.find_for_crowd_username(crowd_username)
        resource = create_from_crowd if !resource && crowd_auto_register?
      end

      if validate(resource)
        return if halted?
        if crowd_allow_forgery_protection? && crowd_unverified_request?
          DeviseCrowd::Logger.send("Can't verify CSRF token authenticity.")
          fail(:crowd_unverified_request)
        else
          DeviseCrowd::Logger.send("authenticated via #{authenticatable_name}!")
          sync_from_crowd(resource) if sync_from_crowd?
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

    def warden
      env['warden']
    end

    def crowd_allow_forgery_protection?
      !!mapping.to.crowd_allow_forgery_protection
    end

    def crowd_unverified_request?
      !!request.env['crowd.unverified_request']
    end

    def crowd_auto_register?
      !!mapping.to.crowd_auto_register
    end

    def crowd_client
      @crowd_client ||= mapping.to.crowd_client
    end

    def cache_authentication
      crowd_session = DeviseCrowd.session(warden, scope)
      crowd_session['crowd.last_auth'] = Time.now
      crowd_session['crowd.last_token'] = crowd_token
      crowd_session['crowd.last_username'] = crowd_username
      DeviseCrowd::Logger.send "Cached crowd authorization.  Next authorization at #{Time.now + mapping.to.crowd_auth_every}."
    end

    # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
    # becomes simply :database.
    def authenticatable_name
      @authenticatable_name ||=
        ActiveSupport::Inflector.underscore(self.class.name.split("::").last).
          sub("_authenticatable", "").to_sym
    end

    def create_from_crowd
      resource = mapping.to.new({mapping.to.crowd_username_key => crowd_username})
      resource.crowd_client = crowd_client
      resource.crowd_record = crowd_record
      result = resource.create_from_crowd
      return nil if result == false
      unless resource.save
        DeviseCrowd::Logger.send("Could not create local user from crowd record (#{resource.errors.messages.inspect})")
        return nil
      end
      DeviseCrowd::Logger.send("Created new local user from crowd record (username=#{crowd_username}).")
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
      DeviseCrowd::Logger.send("Synchronized from crowd record.")
      resource.save
    end
  end
end
