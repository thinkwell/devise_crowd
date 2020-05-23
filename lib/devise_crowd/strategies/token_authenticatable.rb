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
        # try to first authenticate against DB token if exists
        resource = resource_class.find_by_token(crowd_token)
        if resource
          resource.upsert_user_token(crowd_token)
          self.crowd_username = resource.send(resource_class.crowd_username_key)
        end

        unless self.crowd_username
          if DeviseCrowd.crowd_fetch { crowd_client.is_valid_user_token?(crowd_token) }
            Rails.logger.info "DEVISE TOKEN AUTH : #{crowd_token} : is valid in CROWD"
            crowd_session = DeviseCrowd.session(warden, scope)
            if crowd_session['crowd.last_token'] == crowd_token && crowd_session['crowd.last_username']
              self.crowd_username = crowd_session['crowd.last_username']
            else
              self.crowd_record = DeviseCrowd.crowd_fetch { crowd_client.find_user_by_token(crowd_token) }
              if self.crowd_record
                Rails.logger.info "DEVISE TOKEN AUTH : #{crowd_token} : found user by token in CROWD : #{self.crowd_username}"
                resource = resource_class.find_by_username(self.crowd_username)
                # if user does not exist create and update from crowd user
                unless resource
                  resource = resource_class.new
                  resource.update_from_crowd_user self.crowd_record
                  resource.save!
                  Rails.logger.info "DEVISE TOKEN AUTH : #{self.crowd_username} : created user #{resource.id} from CROWD"
                end

                # if successful update user token in DB
                Rails.logger.info "DEVISE TOKEN AUTH : #{self.crowd_username} : update user token in DB"
                resource.upsert_user_token(crowd_token)
              else
                Rails.logger.info "DEVISE TOKEN AUTH : #{crowd_token} : no user found by token in CROWD"
              end
            end
            DeviseCrowd::Logger.send("cannot find user for token key") unless self.crowd_username
          else
            Rails.logger.info "DEVISE TOKEN AUTH : #{crowd_token} : NOT valid in CROWD"
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:crowd_token_authenticatable, Devise::Strategies::CrowdTokenAuthenticatable)
