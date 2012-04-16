module Devise
  module Mock

    class User
      include Mongoid::Document
      devise :crowd_token_authenticatable, :authentication_keys => ['crowd_username']
    end

  end
end
