# This is required to load in task definitions from merb
Dir.glob(File.join(File.dirname(__FILE__),'*.rake')) do |file|
  load file
end
