begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
$KCODE = 'u' unless Cucumber::RUBY_1_9

Before('@not_used') do
  raise "Should never run"
end

After('@not_used') do
  raise "Should never run"
end

Before('@background_tagged_before_on_outline') do
  @cukes = '888'
end

After('@background_tagged_before_on_outline') do
  @cukes.should == '888'
end
