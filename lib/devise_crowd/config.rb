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

  mattr_accessor :crowd_cookie_tokenkey
  @@crowd_cookie_tokenkey = "crowd.token_key"

  mattr_accessor :crowd_param_tokenkey
  @@crowd_param_tokenkey = "crowd.token_key"

  mattr_accessor :crowd_username_field
  @@crowd_username_field = "crowd_username"

  mattr_accessor :crowd_logger
  @@crowd_logger = true

  mattr_accessor :crowd_allow_forgery_protection
  @@crowd_allow_forgery_protection = true

end
