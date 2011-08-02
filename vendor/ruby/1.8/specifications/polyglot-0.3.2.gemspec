# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{polyglot}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Clifford Heath"]
  s.date = %q{2011-07-27}
  s.description = %q{
The Polyglot library allows a Ruby module to register a loader
for the file type associated with a filename extension, and it
augments 'require' to find and load matching files.}
  s.email = ["clifford.heath@gmail.com"]
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["History.txt", "License.txt", "README.txt", "Rakefile", "lib/polyglot.rb", "lib/polyglot/version.rb", "script/txt2html", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.rhtml"]
  s.homepage = %q{http://github.com/cjheath/polyglot}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Augment 'require' to load non-Ruby file types}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
