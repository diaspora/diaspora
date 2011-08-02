Gem::Specification.new do |s|
  s.name      = 'closure-compiler'
  s.version   = '1.1.1'            # Keep version in sync with closure-compiler.rb
  s.date      = '2011-3-23'

  s.homepage    = "http://github.com/documentcloud/closure-compiler/"
  s.summary     = "Ruby Wrapper for the Google Closure Compiler"
  s.description = <<-EOS
    A Ruby Wrapper for the Google Closure Compiler.
  EOS

  s.rubyforge_project = "closure-compiler"
  s.authors           = ['Jeremy Ashkenas', 'Jordan Brough']
  s.email             = 'jeremy@documentcloud.org'

  s.require_paths     = ['lib']

  s.has_rdoc          = true
  s.rdoc_options      << '--title'    << 'Ruby Closure Compiler' <<
                         '--exclude'  << 'test' <<
                         '--all'

  s.files = Dir['lib/**/*', 'vendor/**/*', 'closure-compiler.gemspec', 'README.textile', 'LICENSE', 'COPYING']

end