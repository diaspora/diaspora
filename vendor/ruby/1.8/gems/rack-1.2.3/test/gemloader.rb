require 'rubygems'
project = 'rack'
gemspec = File.expand_path("#{project}.gemspec", Dir.pwd)
Gem::Specification.load(gemspec).dependencies.each do |dep|
  gem dep.name, *dep.requirement.as_list
end