# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{http_connection}
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis Reeder", "RightScale"]
  s.date = %q{2010-10-17}
  s.description = %q{HTTP helper library}
  s.email = %q{travis@appoxy.com}
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["lib/net_fix.rb", "lib/right_http_connection.rb", "README.txt"]
  s.homepage = %q{http://github.com/appoxy/http_connection/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{HTTP helper library}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
