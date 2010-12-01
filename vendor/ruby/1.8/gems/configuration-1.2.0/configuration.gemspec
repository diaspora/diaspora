## configuration.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "configuration"
  spec.version = "1.2.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "configuration"

  spec.files = ["config", "config/a.rb", "config/b.rb", "config/c.rb", "config/d.rb", "config/e.rb", "configuration.gemspec", "lib", "lib/configuration.rb", "LICENSE", "Rakefile", "README", "README.erb", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb"]
  spec.executables = []
  
  
  spec.require_path = "lib"
  

  spec.has_rdoc = true
  spec.test_files = nil
  #spec.add_dependency 'lib', '>= version'
  #spec.add_dependency 'fattr'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/configuration/tree/master"
end
