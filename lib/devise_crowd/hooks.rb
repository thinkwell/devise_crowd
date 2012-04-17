Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]

  if record && record.respond_to?(:needs_crowd_auth?) && warden.authenticated?(scope) && options[:store] != false
    logout = lambda do |msg|
      DeviseCrowd::Logger.send msg if msg
      warden.logout(scope)
    end

    crowd_session = DeviseCrowd.session(warden, scope)
    crowd_token = warden.params[record.class.crowd_token_key] || warden.request.cookies[record.class.crowd_token_key]

    if crowd_session['last_token'] != crowd_token
      logout.call "Re-authorization required.  Crowd token does not match cached token."
    elsif crowd_session['last_auth'] && record.needs_crowd_auth?(crowd_session['last_auth'])
      logout.call "Re-authorization required.  Last authorization was at #{crowd_session['last_auth']}."
    elsif crowd_token && !crowd_session['last_auth']
      logout.call "Re-authorization required.  Unable to determine last authorization time."
    end
  end

end


Warden::Manager.before_logout do |record, warden, options|
  DeviseCrowd.remove_session(warden, options[:scope])
  DeviseCrowd::Logger.send "Removed cached crowd authorization."
end
