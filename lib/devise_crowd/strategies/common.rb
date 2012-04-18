module Devise::Strategies
  module CrowdCommon
    attr_accessor :crowd_username

    private

    def validate_crowd_username!
      resource = mapping.to.find_for_crowd_username(crowd_username) if crowd_username
      if validate(resource)
        return if halted?
        if crowd_allow_forgery_protection? && crowd_unverified_request?
          DeviseCrowd::Logger.send("Can't verify CSRF token authenticity.")
          fail(:crowd_unverified_request)
        else
          DeviseCrowd::Logger.send("authenticated via #{authenticatable_name}!")
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
  end
end
