# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-progressbar}
  s.version = "0.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Satoru Takabayashi"]
  s.date = %q{2009-02-16}
  s.description = %q{Ruby/ProgressBar is a text progress bar library for Ruby.}
  s.email = %q{satoru@namazu.org}
  s.files = ["GPL_LICENSE", "RUBY_LICENSE", "README.md", "lib/progressbar.rb", "test.rb"]
  s.homepage = %q{http://github.com/nex3/ruby-progressbar}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby/ProgressBar is a text progress bar library for Ruby. It can indicate progress with percentage, a progress bar, and estimated remaining time.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
