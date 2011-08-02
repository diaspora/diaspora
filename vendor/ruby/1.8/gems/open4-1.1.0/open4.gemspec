## open4.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "open4"
  spec.version = "1.1.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "open4"
  spec.description = "description: open4 kicks the ass"

  spec.files =
["LICENSE",
 "README",
 "README.erb",
 "Rakefile",
 "lib",
 "lib/open4.rb",
 "open4.gemspec",
 "samples",
 "samples/bg.rb",
 "samples/block.rb",
 "samples/exception.rb",
 "samples/jesse-caldwell.rb",
 "samples/simple.rb",
 "samples/spawn.rb",
 "samples/stdin_timeout.rb",
 "samples/timeout.rb",
 "white_box",
 "white_box/leak.rb"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

### spec.add_dependency 'lib', '>= version'
#### spec.add_dependency 'map'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/open4"
end
