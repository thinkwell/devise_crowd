module DeviseCrowd
  class Railtie < Rails::Railtie
    initializer "devise_crowd.extend_reset_session" do
      ActiveSupport.on_load(:action_controller) do
        require 'devise_crowd/ext/request_forgery_protection.rb'
        include DeviseCrowd::RequestForgeryProtection
      end
    end
  end
end
