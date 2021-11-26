# -*- encoding: utf-8 -*-
# stub: devise_crowd 0.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "devise_crowd".freeze
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brandon Turner".freeze]
  s.date = "2021-06-01"
  s.description = "Crowd authentication for Devise".freeze
  s.email = ["bt@brandonturner.net".freeze]
  s.files = [".gitignore".freeze, ".rspec".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "devise_crowd.gemspec".freeze, "lib/config/locales/en.yml".freeze, "lib/devise_crowd.rb".freeze, "lib/devise_crowd/config.rb".freeze, "lib/devise_crowd/cookie.rb".freeze, "lib/devise_crowd/ext/request_forgery_protection.rb".freeze, "lib/devise_crowd/helpers.rb".freeze, "lib/devise_crowd/hooks.rb".freeze, "lib/devise_crowd/logger.rb".freeze, "lib/devise_crowd/models/common.rb".freeze, "lib/devise_crowd/models/credentials_authenticatable.rb".freeze, "lib/devise_crowd/models/token_authenticatable.rb".freeze, "lib/devise_crowd/railtie.rb".freeze, "lib/devise_crowd/session.rb".freeze, "lib/devise_crowd/strategies/common.rb".freeze, "lib/devise_crowd/strategies/credentials_authenticatable.rb".freeze, "lib/devise_crowd/strategies/token_authenticatable.rb".freeze, "lib/devise_crowd/version.rb".freeze, "spec/mock/strategy.rb".freeze, "spec/mock/user.rb".freeze, "spec/models/common_spec.rb".freeze, "spec/models/credentials_authenticatable_spec.rb".freeze, "spec/models/token_authenticatable_spec.rb".freeze, "spec/rails_app/Rakefile".freeze, "spec/rails_app/app/assets/images/rails.png".freeze, "spec/rails_app/app/assets/javascripts/application.js".freeze, "spec/rails_app/app/assets/stylesheets/application.css".freeze, "spec/rails_app/app/controllers/application_controller.rb".freeze, "spec/rails_app/app/helpers/application_helper.rb".freeze, "spec/rails_app/app/mailers/.gitkeep".freeze, "spec/rails_app/app/models/.gitkeep".freeze, "spec/rails_app/app/views/layouts/application.html.erb".freeze, "spec/rails_app/config.ru".freeze, "spec/rails_app/config/application.rb".freeze, "spec/rails_app/config/boot.rb".freeze, "spec/rails_app/config/database.yml".freeze, "spec/rails_app/config/environment.rb".freeze, "spec/rails_app/config/environments/development.rb".freeze, "spec/rails_app/config/environments/production.rb".freeze, "spec/rails_app/config/environments/test.rb".freeze, "spec/rails_app/config/initializers/backtrace_silencers.rb".freeze, "spec/rails_app/config/initializers/inflections.rb".freeze, "spec/rails_app/config/initializers/mime_types.rb".freeze, "spec/rails_app/config/initializers/secret_token.rb".freeze, "spec/rails_app/config/initializers/session_store.rb".freeze, "spec/rails_app/config/initializers/wrap_parameters.rb".freeze, "spec/rails_app/config/locales/en.yml".freeze, "spec/rails_app/config/routes.rb".freeze, "spec/rails_app/db/seeds.rb".freeze, "spec/rails_app/lib/assets/.gitkeep".freeze, "spec/rails_app/lib/tasks/.gitkeep".freeze, "spec/rails_app/public/404.html".freeze, "spec/rails_app/public/422.html".freeze, "spec/rails_app/public/500.html".freeze, "spec/rails_app/public/favicon.ico".freeze, "spec/rails_app/public/index.html".freeze, "spec/rails_app/public/robots.txt".freeze, "spec/rails_app/script/rails".freeze, "spec/spec_helper.rb".freeze, "spec/strategies/common_spec.rb".freeze, "spec/strategies/credentials_authenticatable_spec.rb".freeze, "spec/strategies/token_authenticatable_spec.rb".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Crowd authentication for Devise".freeze
  s.test_files = ["spec/mock/strategy.rb".freeze, "spec/mock/user.rb".freeze, "spec/models/common_spec.rb".freeze, "spec/models/credentials_authenticatable_spec.rb".freeze, "spec/models/token_authenticatable_spec.rb".freeze, "spec/rails_app/Rakefile".freeze, "spec/rails_app/app/assets/images/rails.png".freeze, "spec/rails_app/app/assets/javascripts/application.js".freeze, "spec/rails_app/app/assets/stylesheets/application.css".freeze, "spec/rails_app/app/controllers/application_controller.rb".freeze, "spec/rails_app/app/helpers/application_helper.rb".freeze, "spec/rails_app/app/mailers/.gitkeep".freeze, "spec/rails_app/app/models/.gitkeep".freeze, "spec/rails_app/app/views/layouts/application.html.erb".freeze, "spec/rails_app/config.ru".freeze, "spec/rails_app/config/application.rb".freeze, "spec/rails_app/config/boot.rb".freeze, "spec/rails_app/config/database.yml".freeze, "spec/rails_app/config/environment.rb".freeze, "spec/rails_app/config/environments/development.rb".freeze, "spec/rails_app/config/environments/production.rb".freeze, "spec/rails_app/config/environments/test.rb".freeze, "spec/rails_app/config/initializers/backtrace_silencers.rb".freeze, "spec/rails_app/config/initializers/inflections.rb".freeze, "spec/rails_app/config/initializers/mime_types.rb".freeze, "spec/rails_app/config/initializers/secret_token.rb".freeze, "spec/rails_app/config/initializers/session_store.rb".freeze, "spec/rails_app/config/initializers/wrap_parameters.rb".freeze, "spec/rails_app/config/locales/en.yml".freeze, "spec/rails_app/config/routes.rb".freeze, "spec/rails_app/db/seeds.rb".freeze, "spec/rails_app/lib/assets/.gitkeep".freeze, "spec/rails_app/lib/tasks/.gitkeep".freeze, "spec/rails_app/public/404.html".freeze, "spec/rails_app/public/422.html".freeze, "spec/rails_app/public/500.html".freeze, "spec/rails_app/public/favicon.ico".freeze, "spec/rails_app/public/index.html".freeze, "spec/rails_app/public/robots.txt".freeze, "spec/rails_app/script/rails".freeze, "spec/spec_helper.rb".freeze, "spec/strategies/common_spec.rb".freeze, "spec/strategies/credentials_authenticatable_spec.rb".freeze, "spec/strategies/token_authenticatable_spec.rb".freeze]

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<simple_crowd>.freeze, [">= 1.1.3"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<devise>.freeze, [">= 2.1.0"])
  else
    s.add_dependency(%q<simple_crowd>.freeze, [">= 1.1.3"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<devise>.freeze, [">= 2.1.0"])
  end
end
