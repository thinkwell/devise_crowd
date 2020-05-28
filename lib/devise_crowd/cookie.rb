module DeviseCrowd

  def self.get_cookie_info(record_class, crowd_client)
    if record_class.cookie_domain
      {domain: record_class.cookie_domain, secure: record_class.cookie_secure}
    else
      Rails.logger.debug "DEVISE CROWD : set_cookie : get_cookie_info"
      DeviseCrowd.crowd_fetch { crowd_client.get_cookie_info }
    end
  end

  def self.set_cookie(token, warden, record_class, crowd_client=nil)
    crowd_client ||= record_class.crowd_client
    cookie_info = self.get_cookie_info(record_class, crowd_client)
    if cookie_info
      warden.cookies[record_class.crowd_token_key] = {
        :domain => cookie_info[:domain],
        :secure => cookie_info[:secure],
        :value => token,
      }
    end
  end

  def self.destroy_cookie(warden, record_class, crowd_client=nil)
    crowd_client ||= record_class.crowd_client
    cookie_info = self.get_cookie_info(record_class, crowd_client)
    if cookie_info
      warden.cookies.delete(record_class.crowd_token_key, :domain => cookie_info[:domain])
    end
  end
end
