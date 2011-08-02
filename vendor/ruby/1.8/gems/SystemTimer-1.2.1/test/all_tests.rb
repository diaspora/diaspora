Dir["#{File.dirname __FILE__}/**/*_test.rb"].each do |test_case| 
  require test_case
end
