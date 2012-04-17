require 'devise_crowd/models/common'
require 'devise_crowd/strategies/token_authenticatable'

module Devise::Models
  module CrowdTokenAuthenticatable
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, CrowdCommon)
    end

    def after_crowd_token_authentication
      after_crowd_authentication
    end

    module ClassMethods
      Devise::Models.config(self, :crowd_token_cookie, :crowd_token_param)
    end
  end
end