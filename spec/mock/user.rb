module Devise
  module Mock

    class User
      include Mongoid::Document
      devise :crowd_token_authenticatable
    end

  end
end
