module Devise::Strategies
  module CrowdCommon

    private

    def validate_crowd_username!(crowd_username)
      resource = mapping.to.find_for_crowd_username(crowd_username)
      if validate(resource)
        return if halted?
        if crowd_allow_forgery_protection? && crowd_unverified_request?
          DeviseCrowd::Logger.send("Can't verify CSRF token authenticity.")
          fail(:crowd_unverified_request)
        else
          DeviseCrowd::Logger.send("authenticated!")
          cache_authentication if store?
          yield(resource) if block_given?
          success!(resource)
        end
      else
        DeviseCrowd::Logger.send("not authenticated!")
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
      crowd_session['last_auth'] = Time.now
      crowd_session['last_token'] = crowd_tokenkey
      DeviseCrowd::Logger.send "Cached crowd authorization.  Next authorization at #{Time.now + mapping.to.crowd_auth_every}."
    end

  end
end