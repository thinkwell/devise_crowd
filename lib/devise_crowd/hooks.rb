Warden::Manager.after_fetch do |record, warden, options|
  scope = options[:scope]

  if record && record.respond_to?(:needs_crowd_auth?) && warden.authenticated?(scope)
    crowd_session = DeviseCrowd.session(warden, scope)
    last_auth = crowd_session['crowd.last_auth']
    if last_auth
      last_token = crowd_session['crowd.last_token']
      crowd_token = warden.params[record.class.crowd_token_key] || warden.request.cookies[record.class.crowd_token_key]

      logout = lambda do |msg|
        DeviseCrowd::Logger.send msg if msg
        warden.set_user(nil, :scope => scope)
      end

      if !crowd_token
        logout.call "Re-authorization required.  Crowd token does not exist."
      elsif last_token != crowd_token
        logout.call "Re-authorization required.  Crowd token does not match cached token."
      elsif last_auth && record.needs_crowd_auth?(last_auth)
        logout.call "Re-authorization required.  Last authorization was at #{last_auth}."
      elsif crowd_token && !last_auth
        logout.call "Re-authorization required.  Unable to determine last authorization time."
      else
        DeviseCrowd::Logger.send "Authenticating from cache.  Next authentication at #{record.next_crowd_auth(last_auth)}"
      end
    end
  end

end


Warden::Manager.before_logout do |record, warden, options|
  scope = options[:scope]
  crowd_session = DeviseCrowd.session(warden, scope)

  if crowd_session['crowd.last_auth']
    DeviseCrowd::Logger.send "Removing crowd cookie"
    DeviseCrowd.destroy_cookie(
      warden,
      record ? record.class : Devise.mappings[options[:scope]].to,
      record ? record.crowd_client : nil
    )
  end

  DeviseCrowd.remove_session(warden, options[:scope])
  DeviseCrowd::Logger.send "Removed cached crowd authorization."
end
