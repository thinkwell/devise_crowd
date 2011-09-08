Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]

  if record && record.respond_to?(:needs_crowd_auth?) && warden.authenticated?(scope) && options[:store] != false
    last_auth_at = warden.session(scope)['last_crowd_auth']

    if last_auth_at && record.needs_crowd_auth?(last_auth_at)
      path_checker = Devise::PathChecker.new(warden.env, scope)
      unless path_checker.signing_out?
        DeviseCrowdAuthenticatable::Logger.send "Re-authorization required. Last authorization was at #{last_auth_at}."
        warden.logout(scope)
      end
    end
  end

end


Warden::Manager.after_authentication do |record, warden, options|
  scope = options[:scope]
  if options[:store] == :crowd && record.class.crowd_auth_every.to_i > 0
    DeviseCrowdAuthenticatable::Logger.send "Caching crowd authorization.  Next authorization at #{Time.now + record.class.crowd_auth_every}."
    warden.session(scope)['last_crowd_auth'] = Time.now
  end
end
