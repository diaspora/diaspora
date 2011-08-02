#     $ ruby -Ilib -Itest -rrubygems test/test_all.rb
#     $ ruby -Ilib -Itest -rrubygems test/transport/test_server_version.rb
Dir.chdir(File.dirname(__FILE__)) do
  test_files = Dir['**/test_*.rb']-['test_all.rb'] # prevent circular require
  test_files = test_files.reject { |f| f =~ /^manual/ }
  test_files = test_files.select { |f| f =~ Regexp.new(ENV['ONLY']) } if ENV['ONLY']
  test_files = test_files.reject { |f| f =~ Regexp.new(ENV['EXCEPT']) } if ENV['EXCEPT']
  test_files.each { |file| require(file) }
end