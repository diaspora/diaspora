# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oauth2-provider}
  s.version = "0.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Ward"]
  s.date = %q{2011-05-17}
  s.description = %q{OAuth2 Provider, extracted from api.hashblue.com}
  s.email = ["tom@popdog.net"]
  s.files = [".gitignore", "Gemfile", "README.md", "Rakefile", "examples/client/Gemfile", "examples/client/Gemfile.lock", "examples/client/README", "examples/client/app.rb", "examples/client/config.ru", "examples/client/views/home.haml", "examples/client/views/response.haml", "examples/rails3-example/.gitignore", "examples/rails3-example/Gemfile", "examples/rails3-example/Gemfile.lock", "examples/rails3-example/README", "examples/rails3-example/Rakefile", "examples/rails3-example/app/controllers/account_controller.rb", "examples/rails3-example/app/controllers/application_controller.rb", "examples/rails3-example/app/controllers/authorization_controller.rb", "examples/rails3-example/app/controllers/home_controller.rb", "examples/rails3-example/app/controllers/session_controller.rb", "examples/rails3-example/app/helpers/application_helper.rb", "examples/rails3-example/app/models/account.rb", "examples/rails3-example/app/views/authorization/new.html.erb", "examples/rails3-example/app/views/home/show.html.erb", "examples/rails3-example/app/views/layouts/application.html.erb", "examples/rails3-example/app/views/session/new.html.erb", "examples/rails3-example/config.ru", "examples/rails3-example/config/application.rb", "examples/rails3-example/config/boot.rb", "examples/rails3-example/config/database.yml", "examples/rails3-example/config/environment.rb", "examples/rails3-example/config/environments/development.rb", "examples/rails3-example/config/environments/production.rb", "examples/rails3-example/config/environments/test.rb", "examples/rails3-example/config/initializers/backtrace_silencers.rb", "examples/rails3-example/config/initializers/inflections.rb", "examples/rails3-example/config/initializers/mime_types.rb", "examples/rails3-example/config/initializers/secret_token.rb", "examples/rails3-example/config/initializers/session_store.rb", "examples/rails3-example/config/locales/en.yml", "examples/rails3-example/config/routes.rb", "examples/rails3-example/db/migrate/20110508151935_add_account_table.rb", "examples/rails3-example/db/migrate/20110508151948_add_oauth2_tables.rb", "examples/rails3-example/db/schema.rb", "examples/rails3-example/db/seeds.rb", "examples/rails3-example/doc/README_FOR_APP", "examples/rails3-example/lib/tasks/.gitkeep", "examples/rails3-example/public/404.html", "examples/rails3-example/public/422.html", "examples/rails3-example/public/500.html", "examples/rails3-example/public/favicon.ico", "examples/rails3-example/public/images/rails.png", "examples/rails3-example/public/robots.txt", "examples/rails3-example/public/stylesheets/.gitkeep", "examples/rails3-example/script/rails", "lib/oauth2-provider.rb", "lib/oauth2/provider.rb", "lib/oauth2/provider/models.rb", "lib/oauth2/provider/models/access_token.rb", "lib/oauth2/provider/models/active_record.rb", "lib/oauth2/provider/models/active_record/access_token.rb", "lib/oauth2/provider/models/active_record/authorization.rb", "lib/oauth2/provider/models/active_record/authorization_code.rb", "lib/oauth2/provider/models/active_record/client.rb", "lib/oauth2/provider/models/authorization.rb", "lib/oauth2/provider/models/authorization_code.rb", "lib/oauth2/provider/models/client.rb", "lib/oauth2/provider/models/mongoid.rb", "lib/oauth2/provider/models/mongoid/access_token.rb", "lib/oauth2/provider/models/mongoid/authorization.rb", "lib/oauth2/provider/models/mongoid/authorization_code.rb", "lib/oauth2/provider/models/mongoid/client.rb", "lib/oauth2/provider/rack.rb", "lib/oauth2/provider/rack/access_token_handler.rb", "lib/oauth2/provider/rack/authorization_code_request.rb", "lib/oauth2/provider/rack/authorization_codes_support.rb", "lib/oauth2/provider/rack/middleware.rb", "lib/oauth2/provider/rack/resource_request.rb", "lib/oauth2/provider/rack/responses.rb", "lib/oauth2/provider/rails.rb", "lib/oauth2/provider/rails/controller_authentication.rb", "lib/oauth2/provider/random.rb", "lib/oauth2/provider/version.rb", "oauth2-provider.gemspec", "spec/models/access_token_spec.rb", "spec/models/authorization_code_spec.rb", "spec/models/authorization_spec.rb", "spec/models/client_spec.rb", "spec/requests/access_tokens_controller_spec.rb", "spec/requests/authentication_spec.rb", "spec/requests/authorization_codes_support_spec.rb", "spec/schema.rb", "spec/set_backend_env_to_mongoid.rb", "spec/spec_helper.rb", "spec/support/activerecord_backend.rb", "spec/support/factories.rb", "spec/support/macros.rb", "spec/support/mongoid_backend.rb", "spec/support/rack.rb"]
  s.homepage = %q{http://tomafro.net}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OAuth2 Provider, extracted from api.hashblue.com}
  s.test_files = ["spec/models/access_token_spec.rb", "spec/models/authorization_code_spec.rb", "spec/models/authorization_spec.rb", "spec/models/client_spec.rb", "spec/requests/access_tokens_controller_spec.rb", "spec/requests/authentication_spec.rb", "spec/requests/authorization_codes_support_spec.rb", "spec/schema.rb", "spec/set_backend_env_to_mongoid.rb", "spec/spec_helper.rb", "spec/support/activerecord_backend.rb", "spec/support/factories.rb", "spec/support/macros.rb", "spec/support/mongoid_backend.rb", "spec/support/rack.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.1"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.2"])
      s.add_development_dependency(%q<rails>, ["~> 3.0.1"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.1.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_development_dependency(%q<timecop>, ["~> 0.3.4"])
      s.add_development_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
      s.add_development_dependency(%q<mongoid>, ["= 2.0.0.rc.6"])
      s.add_development_dependency(%q<bson>, ["= 1.2.0"])
      s.add_development_dependency(%q<bson_ext>, ["= 1.2.0"])
      s.add_development_dependency(%q<sdoc>, ["~> 0.2.20"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.1"])
      s.add_dependency(%q<addressable>, ["~> 2.2"])
      s.add_dependency(%q<rails>, ["~> 3.0.1"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.1.0"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_dependency(%q<timecop>, ["~> 0.3.4"])
      s.add_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
      s.add_dependency(%q<mongoid>, ["= 2.0.0.rc.6"])
      s.add_dependency(%q<bson>, ["= 1.2.0"])
      s.add_dependency(%q<bson_ext>, ["= 1.2.0"])
      s.add_dependency(%q<sdoc>, ["~> 0.2.20"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.1"])
    s.add_dependency(%q<addressable>, ["~> 2.2"])
    s.add_dependency(%q<rails>, ["~> 3.0.1"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.1.0"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
    s.add_dependency(%q<timecop>, ["~> 0.3.4"])
    s.add_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
    s.add_dependency(%q<mongoid>, ["= 2.0.0.rc.6"])
    s.add_dependency(%q<bson>, ["= 1.2.0"])
    s.add_dependency(%q<bson_ext>, ["= 1.2.0"])
    s.add_dependency(%q<sdoc>, ["~> 0.2.20"])
  end
end
