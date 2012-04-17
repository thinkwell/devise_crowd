module Devise
  module Mock

    class User
      include Mongoid::Document
      devise :crowd_token_authenticatable, :crowd_credentials_authenticatable, :authentication_keys => ['username']
    end

  end
end
