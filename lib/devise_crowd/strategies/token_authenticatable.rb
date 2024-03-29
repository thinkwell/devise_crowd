require 'devise/strategies/base'
require 'devise_crowd/strategies/common'

module Devise::Strategies
  class CrowdTokenAuthenticatable < Base
    include CrowdCommon

    def valid?
      valid_for_crowd_token_auth?
    end

    def authenticate!
      authenticate_crowd_token
      unless crowd_username
        DeviseCrowd::Logger.send "not authenticated via #{authenticatable_name} (invalid token)!"
        return fail(:crowd_invalid_token)
      end

      validate_crowd_username! do |resource|
        resource.after_crowd_token_authentication
      end
    end

    # Store user information in a session if crowd_auth_every is set
    def store?
      !resource_class.skip_session_storage.include?(:crowd_token_auth) &&
        resource_class.crowd_auth_every.to_i > 0
    end


  private
    # Simply invokes valid_for_authentication? with the given block and deal with the result.
    def validate(resource, &block)
      result = resource && resource.valid_for_authentication?(&block)

      case result
      when String, Symbol
        fail!(result)
        false
      when TrueClass
        true
      else
        result
      end
    end

    def crowd_enabled?
      resource_class.crowd_enabled?(:crowd_token)
    end

    def valid_for_crowd_token_auth?
      crowd_enabled? && has_crowd_token?
    end

    def has_crowd_token?
      !!crowd_token
    end

    def crowd_token
      crowd_token_param || crowd_token_cookie
    end

    def crowd_token_cookie
      request.cookies[resource_class.crowd_token_key]
    end

    def crowd_token_param
      params[resource_class.crowd_token_key]
    end

    def authenticate_crowd_token
      self.crowd_record = nil
      if has_crowd_token?
        if DeviseCrowd.crowd_fetch { crowd_client.is_valid_user_token?(crowd_token) }
          crowd_session = DeviseCrowd.session(warden, scope)
          if crowd_session['crowd.last_token'] == crowd_token && crowd_session['crowd.last_username']
            self.crowd_username = crowd_session['crowd.last_username']
          else
            self.crowd_record = DeviseCrowd.crowd_fetch { crowd_client.find_user_by_token(crowd_token) }
          end
          DeviseCrowd::Logger.send("cannot find user for token key") unless self.crowd_username
        end
      end
    end
  end
end

Warden::Strategies.add(:crowd_token_authenticatable, Devise::Strategies::CrowdTokenAuthenticatable)
