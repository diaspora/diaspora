Dir.chdir(File.dirname(__FILE__)) do
  Dir['**/test_*.rb'].each { |file| require(file) }
end