require 'devise/strategies/authenticatable'

module Devise::Strategies
  class CrowdTokenAuthenticatable < Authenticatable
    def valid?
      valid_for_crowd_token_auth?
    end

    def authenticate!
      # Do the crowd lookup and insert into authentication_hash
      crowd_auth_hash = crowd_auth_hash()
      with_authentication_hash(:crowd_auth, crowd_auth_hash)
      unless authentication_hash.length > 0
        DeviseCrowd::Logger.send "not authenticated!"
        DeviseCrowd::Logger.send "try using string authentication_keys (\"#{mapping.to.crowd_username_field}\") instead of symbols" if crowd_auth_hash.has_key?(mapping.to.crowd_username_field.to_s) && authentication_keys.has_key?(mapping.to.crowd_username_field.to_sym)
        return fail(:crowd_invalid)
      end

      resource = mapping.to.find_for_crowd_authentication(authentication_hash)
      if validate(resource)
        return if halted?
        if crowd_allow_forgery_protection? && crowd_unverified_request?
          DeviseCrowd::Logger.send("Can't verify CSRF token authenticity.")
          return fail(:crowd_unverified_request)
        end
        DeviseCrowd::Logger.send("authenticated!")
        cache_authentication if store?
        resource.after_crowd_authentication
        success!(resource)
      else
        DeviseCrowd::Logger.send("not authenticated!")
        return if halted?
        fail(:crowd_unknown_user)
      end
    end

    # Store user information in a session if crowd_auth_every is set
    def store?
      mapping.to.crowd_auth_every.to_i > 0
    end


  private

    def warden
      env['warden']
    end

    def valid_for_crowd_token_auth?
      crowd_enabled? && has_crowd_tokenkey?
    end

    def crowd_enabled?
      mapping.to.crowd_enabled?(authenticatable_name)
    end

    def has_crowd_tokenkey?
      !!crowd_tokenkey
    end

    def crowd_tokenkey
      crowd_token_param || crowd_token_cookie
    end

    def crowd_token_cookie
      request.cookies[mapping.to.crowd_token_cookie]
    end

    def crowd_allow_forgery_protection?
      !!mapping.to.crowd_allow_forgery_protection
    end

    def crowd_unverified_request?
      !!request.env['crowd.unverified_request']
    end

    def crowd_token_param
      params[mapping.to.crowd_token_param]
    end

    def crowd_auth_hash
      auth_hash = {}
      if has_crowd_tokenkey?
        if crowd_client.is_valid_user_token?(crowd_tokenkey)
          username = crowd_client.find_username_by_token(crowd_tokenkey)
          if username
            auth_hash[mapping.to.crowd_username_field.to_s] = username
          else
            DeviseCrowd::Logger.send("cannot find username for token key")
          end
        else
          DeviseCrowd::Logger.send("invalid token key")
        end
      end

      auth_hash
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

Warden::Strategies.add(:crowd_token_authenticatable, Devise::Strategies::CrowdTokenAuthenticatable)
