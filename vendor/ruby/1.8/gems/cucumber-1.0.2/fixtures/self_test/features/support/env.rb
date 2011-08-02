require 'base64'
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

After do
  png = IO.read(File.join(File.dirname(__FILE__), 'bubble_256x256.png'))
  encoded_img = Base64.encode64(png).gsub(/\n/, '')
  embed("data:image/png;base64,#{encoded_img}", 'image/png')
end

