module Devise
  module Mock
    class User
      include Mongoid::Document
      devise :crowd_token_authenticatable, :crowd_credentials_authenticatable

      before_create_from_crowd :allow_create_from_crowd?
      before_sync_from_crowd :allow_sync_from_crowd?

      def allow_create_from_crowd?
        true
      end

      def allow_sync_from_crowd?
        true
      end
    end
  end
end
