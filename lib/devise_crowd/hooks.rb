Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]

  if record && record.respond_to?(:needs_crowd_auth?) && warden.authenticated?(scope) && options[:store] != false
    last_auth = DeviseCrowd.session(warden, scope)['last_auth']

    if last_auth && record.needs_crowd_auth?(last_auth)
      path_checker = Devise::PathChecker.new(warden.env, scope)
      unless path_checker.signing_out?
        DeviseCrowd::Logger.send "Re-authorization required. Last authorization was at #{last_auth}."
        warden.logout(scope)
      end
    end
  end

end


Warden::Manager.before_logout do |record, warden, options|
  DeviseCrowd.remove_session(warden, options[:scope])
  DeviseCrowd::Logger.send "Removed cached crowd authorization."
end
