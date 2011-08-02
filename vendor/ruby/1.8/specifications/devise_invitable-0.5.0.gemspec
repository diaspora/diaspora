# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{devise_invitable}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sergio Cambra"]
  s.date = %q{2011-05-09}
  s.description = %q{It adds support for send invitations by email (it requires to be authenticated) and accept the invitation by setting a password.}
  s.email = ["sergio@entrecables.com"]
  s.files = ["app/controllers/devise/invitations_controller.rb", "app/views/devise/invitations/edit.html.erb", "app/views/devise/invitations/new.html.erb", "app/views/devise/mailer/invitation_instructions.html.erb", "config/locales/en.yml", "lib/devise_invitable.rb", "lib/devise_invitable/mailer.rb", "lib/devise_invitable/model.rb", "lib/devise_invitable/rails.rb", "lib/devise_invitable/routes.rb", "lib/devise_invitable/schema.rb", "lib/devise_invitable/controllers/helpers.rb", "lib/devise_invitable/controllers/url_helpers.rb", "lib/devise_invitable/version.rb", "lib/devise_invitable/inviter.rb", "lib/generators/active_record/devise_invitable_generator.rb", "lib/generators/active_record/templates/migration.rb", "lib/generators/devise_invitable/views_generator.rb", "lib/generators/devise_invitable/devise_invitable_generator.rb", "lib/generators/devise_invitable/install_generator.rb", "lib/generators/mongoid/devise_invitable_generator.rb", "LICENSE", "README.rdoc"]
  s.homepage = %q{https://github.com/scambra/devise_invitable}
  s.rdoc_options = ["--main", "README.rdoc", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An invitation strategy for Devise}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.7"])
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0", "<= 3.2"])
      s.add_runtime_dependency(%q<devise>, ["~> 1.3.1"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.7"])
      s.add_dependency(%q<rails>, [">= 3.0.0", "<= 3.2"])
      s.add_dependency(%q<devise>, ["~> 1.3.1"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.7"])
    s.add_dependency(%q<rails>, [">= 3.0.0", "<= 3.2"])
    s.add_dependency(%q<devise>, ["~> 1.3.1"])
  end
end
