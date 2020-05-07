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
      authenticate_crowd_credentials
      unless crowd_username
        DeviseCrowd::Logger.send "not authenticated via #{authenticatable_name} (invalid credentials)!"
        return fail(:crowd_invalid_credentials)
      end

      validate_crowd_username! do |resource|
        DeviseCrowd.set_cookie(crowd_token, warden, resource_class, crowd_client)
        resource.after_crowd_credentials_authentication
      end
    end

    def store?
      !resource_class.skip_session_storage.include?(:crowd_credentials_auth) &&
        resource_class.crowd_auth_every.to_i > 0
    end

  private

    def crowd_enabled?
      resource_class.crowd_enabled?(:crowd_credentials)
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
      username = authentication_hash[resource_class.crowd_username_key]

      if username
        # try to first authenticate against DB password if exists
        resource = resource_class.find_by_username(username)
        if resource && resource.valid_password?(password)
          token = resource.get_or_create_token
        end

        # if DB authentication not successful try against crowd
        unless token
          Rails.logger.debug "AUTHENTICATE : #{username} : in CROWD ..."
          token = DeviseCrowd.crowd_fetch { crowd_client.authenticate_user(username, password) }

          if token
            # if user does not exist create and update from crowd user
            unless resource
              resource = resource_class.new
              crowd_user = DeviseCrowd.crowd_fetch { crowd_client.find_user_by_name(username) }
              resource.update_from_crowd_user crowd_user
              Rails.logger.debug "AUTHENTICATE : #{username} : created user from CROWD #{crowd_user.inspect}"
            end

            # if successful update password hash in DB via devise
            Rails.logger.debug "AUTHENTICATE : #{username} : update password in DB"
            resource.password = password
            resource.save!
          end
        end
      end

      if token
        self.crowd_token = token
        self.crowd_username = username
      else
        self.crowd_token = self.crowd_username = nil
      end
    end

  end
end

Warden::Strategies.add(:crowd_credentials_authenticatable, Devise::Strategies::CrowdCredentialsAuthenticatable)
