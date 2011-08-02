## systemu.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "systemu"
  spec.version = "2.2.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "systemu"
  spec.description = "description: systemu kicks the ass"

  spec.files = ["lib", "lib/systemu.rb", "LICENSE", "Rakefile", "README", "README.erb", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb", "samples/f.rb", "systemu.gemspec"]
  spec.executables = []
  
  spec.require_path = "lib"

  spec.has_rdoc = true
  spec.test_files = nil

# spec.add_dependency 'lib', '>= version'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/systemu"
end
