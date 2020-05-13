module Devise

  # Tell if authentication through Crowd is enabled.  False by default.
  mattr_accessor :crowd_enabled
  @@crowd_enabled = false

  mattr_accessor :crowd_service_url
  @@crowd_service_url = "http://localhost:8095/crowd"

  mattr_accessor :crowd_noop
  @@crowd_noop = false

  mattr_accessor :crowd_app_name
  @@crowd_app_name = "crowd"

  mattr_accessor :crowd_app_password
  @@crowd_app_password = ""

  mattr_accessor :crowd_auth_every
  @@crowd_auth_every = 0

  mattr_accessor :crowd_token_key
  @@crowd_token_key = "crowd.token_key"

  # The name of the crowd username parameter/field.  If nil (default), the
  # first authentication_keys key will be used (e.g. email).
  mattr_accessor :crowd_username_key
  @@crowd_username_key = nil

  mattr_accessor :crowd_logger
  @@crowd_logger = true

  mattr_accessor :crowd_allow_forgery_protection
  @@crowd_allow_forgery_protection = true

  mattr_accessor :crowd_auto_register
  @@crowd_auto_register = true

  mattr_accessor :cookie_domain
  @@cookie_domain = nil

  mattr_accessor :cookie_secure
  @@cookie_secure = nil

  mattr_accessor :add_crowd_records
  @@add_crowd_records = false

  mattr_accessor :update_crowd_records
  @@update_crowd_records = true
end
