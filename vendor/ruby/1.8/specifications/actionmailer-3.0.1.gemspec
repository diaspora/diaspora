# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{actionmailer}
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = %q{2010-10-14}
  s.description = %q{Email on Rails. Compose, deliver, receive, and test emails using the familiar controller/view pattern. First-class support for multipart email and attachments.}
  s.email = %q{david@loudthinking.com}
  s.files = ["CHANGELOG", "README.rdoc", "MIT-LICENSE", "lib/action_mailer/adv_attr_accessor.rb", "lib/action_mailer/base.rb", "lib/action_mailer/collector.rb", "lib/action_mailer/delivery_methods.rb", "lib/action_mailer/deprecated_api.rb", "lib/action_mailer/log_subscriber.rb", "lib/action_mailer/mail_helper.rb", "lib/action_mailer/old_api.rb", "lib/action_mailer/railtie.rb", "lib/action_mailer/test_case.rb", "lib/action_mailer/test_helper.rb", "lib/action_mailer/tmail_compat.rb", "lib/action_mailer/version.rb", "lib/action_mailer.rb", "lib/rails/generators/mailer/mailer_generator.rb", "lib/rails/generators/mailer/templates/mailer.rb", "lib/rails/generators/mailer/USAGE"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.requirements = ["none"]
  s.rubyforge_project = %q{actionmailer}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Email composition, delivery, and receiving framework (part of Rails).}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>, ["= 3.0.1"])
      s.add_runtime_dependency(%q<mail>, ["~> 2.2.5"])
    else
      s.add_dependency(%q<actionpack>, ["= 3.0.1"])
      s.add_dependency(%q<mail>, ["~> 2.2.5"])
    end
  else
    s.add_dependency(%q<actionpack>, ["= 3.0.1"])
    s.add_dependency(%q<mail>, ["~> 2.2.5"])
  end
end
