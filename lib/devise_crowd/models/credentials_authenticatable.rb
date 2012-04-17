require 'devise_crowd/models/common'
require 'devise_crowd/strategies/credentials_authenticatable'

module Devise::Models
  module CrowdCredentialsAuthenticatable
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, CrowdCommon)
      unless base.method_defined?(:password=)
        base.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def password=(p)
          end
        METHOD
      end
    end

    def after_crowd_credentials_authentication
      after_crowd_authentication
    end

    module ClassMethods
      Devise::Models.config(self, :crowd_username_param)
    end
  end
end
