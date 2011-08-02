Gem::Specification.new do |s|
  s.name = 'bcrypt-ruby'
  s.version = '2.1.4'

  s.summary = "OpenBSD's bcrypt() password hashing algorithm."
  s.description = <<-EOF
    bcrypt() is a sophisticated and secure hash algorithm designed by The OpenBSD project
    for hashing passwords. bcrypt-ruby provides a simple, humane wrapper for safely handling
    passwords.
  EOF

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rspec'

  s.has_rdoc = true
  s.rdoc_options += ['--title', 'bcrypt-ruby', '--line-numbers', '--inline-source', '--main', 'README']
  s.extra_rdoc_files += ['README', 'COPYING', 'CHANGELOG', *Dir['lib/**/*.rb']]

  s.extensions = 'ext/mri/extconf.rb'

  s.authors = ["Coda Hale"]
  s.email = "coda.hale@gmail.com"
  s.homepage = "http://bcrypt-ruby.rubyforge.org"
  s.rubyforge_project = "bcrypt-ruby"
end
