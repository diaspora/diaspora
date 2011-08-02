Given /^I have jruby installed$/ do
  @jruby_cmd = `which jruby`.strip
  raise "Need to setup @jruby_cmd to test jruby environment" if @jruby_cmd.blank?
end

Then /^the gem "([^\"]*)" is installed into jruby environment$/ do |gem_name|
  raise "Need to setup @jruby_cmd to test jruby environment" if @jruby_cmd.blank?
  gem_list = `#{@jruby_cmd} -S gem list #{gem_name}`
  gem_list.should =~ /#{gem_name}/
end

