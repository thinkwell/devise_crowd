module DeviseCrowd
  module RequestForgeryProtection
    extend ActiveSupport::Concern

    protected
    def handle_unverified_request
      ret = super
      request.env['crowd.unverified_request'] = true
      ret
    end
  end
end
