Dir["#{File.dirname(__FILE__)}/**/*_spec.rb"].each do |file|
  require file
end