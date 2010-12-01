lib, version = File::basename(File::dirname(File::expand_path(__FILE__))).split %r/-/, 2

require 'rubygems'

Gem::Specification::new do |spec|
  spec.name = lib 
  spec.version = version 
  spec.platform = Gem::Platform::RUBY
  spec.summary = lib 

  spec.files = Dir::glob "**/**"
  spec.executables = Dir::glob("bin/*").map{|exe| File::basename exe}
  
  spec.require_path = "lib" 
  spec.autorequire = lib

  spec.has_rdoc = File::exist? "doc" 
  spec.test_suite_file = "test/#{ lib }.rb" if File::directory? "test"

  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@noaa.gov"
  spec.homepage = "http://codeforpeople.com/lib/ruby/#{ lib }/"
end
