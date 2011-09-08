require 'devise/strategies/authenticatable'

module Devise::Strategies
  class CrowdAuthenticatable < Authenticatable
    def valid?
      valid_for_crowd_auth?
    end

    def authenticate!
      # Do the crowd lookup and insert into authentication_hash
      with_authentication_hash(crowd_auth_hash)
      return fail(:crowd_invalid) unless authentication_hash.length > 0

      resource = mapping.to.find_for_crowd_authentication(authentication_hash)
      if validate(resource)
        return if halted?
        DeviseCrowdAuthenticatable::Logger.send("authenticated!")
        resource.after_crowd_authentication
        success!(resource)
      else
        DeviseCrowdAuthenticatable::Logger.send("not authenticated!")
        return if halted?
        fail(:crowd_unknown_user)
      end
    end

    # Store user information in a session and
    # HACK: Use :crowd instead of true so that the after_authentication hook
    # can set the last_crowd_auth timeout
    def store?
      mapping.to.crowd_auth_every.to_i > 0 ? :crowd : false
    end


  private

    def valid_for_crowd_auth?
      crowd_enabled? && has_crowd_tokenkey?
    end

    def crowd_enabled?
      mapping.to.crowd_enabled?(authenticatable_name)
    end

    def has_crowd_tokenkey?
      !!crowd_tokenkey
    end

    def crowd_tokenkey
      crowd_param_tokenkey || crowd_cookie_tokenkey
    end

    def crowd_cookie_tokenkey
      request.cookies[mapping.to.crowd_cookie_tokenkey]
    end

    def crowd_param_tokenkey
      params[mapping.to.crowd_param_tokenkey]
    end

    def crowd_auth_hash
      # TODO: Authenticate the crowd token and return the crowd username
      # in a hash:
      {mapping.to.crowd_username_field => 'blt04'}
    end

  end
end

Warden::Strategies.add(:crowd_authenticatable, Devise::Strategies::CrowdAuthenticatable)
