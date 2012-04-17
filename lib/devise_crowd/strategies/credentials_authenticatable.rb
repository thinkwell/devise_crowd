require 'devise/strategies/base'
require 'devise_crowd/strategies/common'

module Devise::Strategies
  class CrowdCredentialsAuthenticatable < Authenticatable
    include CrowdCommon
    attr_accessor :crowd_token

    def valid?
      valid_for_credentials_auth?
    end

    def authenticate!
      crowd_username = authenticate_crowd_credentials
      unless crowd_username
        DeviseCrowd::Logger.send "not authenticated!"
        return fail(:crowd_invalid_credentials)
      end

      validate_crowd_username!(crowd_username) do |resource|
        cookie_info = DeviseCrowd.crowd_fetch { crowd_client.get_cookie_info }
        if cookie_info
          warden.warden_cookies[mapping.to.crowd_token_key] = {
            :domain => cookie_info[:domain],
            :secure => cookie_info[:secure],
            :value => crowd_token,
          }
        end
        resource.after_crowd_credentials_authentication
      end
    end

    def store?
      !mapping.to.skip_session_storage.include?(:crowd_credentials_auth) &&
        mapping.to.crowd_auth_every.to_i > 0
    end

  private

    def crowd_enabled?
      mapping.to.crowd_enabled?(:crowd_credentials)
    end

    def valid_for_credentials_auth?
      crowd_enabled? && valid_params? &&
        with_authentication_hash(:crowd_credentials_auth, params_auth_hash)
    end

    def params_auth_hash
      params[scope]
    end

    def valid_params?
      params_auth_hash.is_a?(Hash)
    end

    def authenticate_crowd_credentials
      username = authentication_hash[mapping.to.crowd_username_key]
      token = DeviseCrowd.crowd_fetch { crowd_client.authenticate_user(username, password) } if username

      if token
        self.crowd_token = token
      else
        self.crowd_token = username = nil
        DeviseCrowd::Logger.send("invalid credentials")
      end

      username
    end

  end
end

Warden::Strategies.add(:crowd_credentials_authenticatable, Devise::Strategies::CrowdCredentialsAuthenticatable)
