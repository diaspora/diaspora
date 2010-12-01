# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pyu-ruby-sasl}
  s.version = "0.0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephan Maka", "Ping Yu"]
  s.date = %q{2010-10-18}
  s.description = %q{Simple Authentication and Security Layer (RFC 4422)}
  s.email = %q{pyu@intridea.com}
  s.files = ["spec/mechanism_spec.rb", "spec/anonymous_spec.rb", "spec/plain_spec.rb", "spec/digest_md5_spec.rb", "lib/sasl/base.rb", "lib/sasl/digest_md5.rb", "lib/sasl/anonymous.rb", "lib/sasl/plain.rb", "lib/sasl/base64.rb", "lib/sasl.rb", "README.markdown"]
  s.homepage = %q{http://github.com/pyu10055/ruby-sasl/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{SASL client library}
  s.test_files = ["spec/mechanism_spec.rb", "spec/anonymous_spec.rb", "spec/plain_spec.rb", "spec/digest_md5_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
