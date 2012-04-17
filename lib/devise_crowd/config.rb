module Devise

  # Tell if authentication through Crowd is enabled.  False by default.
  mattr_accessor :crowd_enabled
  @@crowd_enabled = false

  mattr_accessor :crowd_service_url
  @@crowd_service_url = "http://localhost:8095/crowd"

  mattr_accessor :crowd_app_name
  @@crowd_app_name = "crowd"

  mattr_accessor :crowd_app_password
  @@crowd_app_password = ""

  mattr_accessor :crowd_auth_every
  @@crowd_auth_every = 10.minutes

  mattr_accessor :crowd_token_cookie
  @@crowd_token_cookie = "crowd.token_key"

  mattr_accessor :crowd_token_param
  @@crowd_token_param = "crowd.token_key"

  mattr_accessor :crowd_username_field
  @@crowd_username_field = "crowd_username"

  # The name of the username parameter.  If nil (default), the
  # first available authentication_keys key will be used.
  mattr_accessor :crowd_username_param
  @@crowd_username_param = nil

  mattr_accessor :crowd_logger
  @@crowd_logger = true

  mattr_accessor :crowd_allow_forgery_protection
  @@crowd_allow_forgery_protection = true

end
