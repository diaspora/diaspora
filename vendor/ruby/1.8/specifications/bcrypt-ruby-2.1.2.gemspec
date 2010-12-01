# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bcrypt-ruby}
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Coda Hale"]
  s.date = %q{2009-09-16}
  s.description = %q{    bcrypt() is a sophisticated and secure hash algorithm designed by The OpenBSD project
    for hashing passwords. bcrypt-ruby provides a simple, humane wrapper for safely handling
    passwords.
}
  s.email = %q{coda.hale@gmail.com}
  s.extensions = ["ext/mri/extconf.rb"]
  s.extra_rdoc_files = ["README", "COPYING", "CHANGELOG", "lib/bcrypt.rb"]
  s.files = ["CHANGELOG", "COPYING", "Rakefile", "README", "lib/bcrypt.rb", "spec/bcrypt/engine_spec.rb", "spec/bcrypt/password_spec.rb", "spec/spec_helper.rb", "ext/mri/bcrypt.c", "ext/mri/bcrypt_ext.c", "ext/mri/blowfish.c", "ext/mri/bcrypt.h", "ext/mri/blf.h", "ext/mri/extconf.rb", "ext/jruby/bcrypt_jruby/BCrypt.java", "ext/jruby/bcrypt_jruby/BCrypt.class"]
  s.homepage = %q{http://bcrypt-ruby.rubyforge.org}
  s.rdoc_options = ["--title", "bcrypt-ruby", "--line-numbers", "--inline-source", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{bcrypt-ruby}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OpenBSD's bcrypt() password hashing algorithm.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
