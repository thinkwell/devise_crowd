module DeviseCrowd

  def self.set_cookie(token, warden, record_class, crowd_client=nil)
    crowd_client ||= record_class.crowd_client
    cookie_info = DeviseCrowd.crowd_fetch { crowd_client.get_cookie_info }
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
    cookie_info = DeviseCrowd.crowd_fetch { crowd_client.get_cookie_info }
    if cookie_info
      warden.cookies.delete(record_class.crowd_token_key, :domain => cookie_info[:domain])
    end
  end
end
