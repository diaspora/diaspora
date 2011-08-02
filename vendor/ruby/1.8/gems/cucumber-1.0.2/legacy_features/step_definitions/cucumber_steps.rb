# encoding: utf-8
require 'tempfile'

Given /^I am in (.*)$/ do |example_dir_relative_path|
  @current_dir = fixtures_dir(example_dir_relative_path)
end

Given /^a standard Cucumber project directory structure$/ do
  @current_dir = working_dir
  in_current_dir do
    FileUtils.rm_rf 'features' if File.directory?('features')
    FileUtils.mkdir_p 'features/support'
    FileUtils.mkdir 'features/step_definitions'
  end
end

Given /^the (.*) directory is empty$/ do |directory|
  in_current_dir do
    FileUtils.remove_dir(directory) rescue nil
    FileUtils.mkdir 'tmp'
  end
end

Given /^a file named "([^"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

Given /^the following profiles? (?:are|is) defined:$/ do |profiles|
  create_file('cucumber.yml', profiles)
end

Given /^I am running spork in the background$/ do
  run_spork_in_background
end

Given /^I am running spork in the background on port (\d+)$/ do |port|
  run_spork_in_background(port.to_i)
end

Given /^I am not running (?:.*) in the background$/ do
  # no-op
end

Given /^I have environment variable (\w+) set to "([^"]*)"$/ do |variable, value|
  set_env_var(variable, value)
end

When /^I run cucumber (.*)$/ do |cucumber_opts|
  run "#{Cucumber::RUBY_BINARY} -I rubygems #{cucumber_bin} --no-color #{cucumber_opts} CUCUMBER_OUTPUT_ENCODING=UTF-8"
end

When /^I run rake (.*)$/ do |rake_opts|
  run "rake #{rake_opts} --trace"
end

When /^I run the following Ruby code:$/ do |code|
  run %{#{Cucumber::RUBY_BINARY} -r rubygems -I #{cucumber_lib_dir} -e "#{code}"}
end

Then /^it should (fail|pass)$/ do |success|
  if success == 'fail'
    last_exit_status.should_not == 0
  else
    if last_exit_status != 0
      raise "Failed with exit status #{last_exit_status}\nSTDOUT:\n#{last_stdout}\nSTDERR:\n#{last_stderr}"
    end
  end
end

Then /^it should (fail|pass) with$/ do |success, output|
  unless combined_output.index(output)
    combined_output.should == output
  end
  Then("it should #{success}")
end

Then /^the output should contain "([^"]*)"$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should contain:?$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should not contain$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should be$/ do |text|
  last_stdout.should == text
end

Then /^it should (fail|pass) with JSON$/ do |success, text|
  JSON.parse(last_stdout).should == JSON.parse(text)
  Then("it should #{success}")
end

Then /^"([^"]*)" should contain$/ do |file, text|
  strip_duration(IO.read(file)).should == text
end

Then /^"([^"]*)" with junit duration "([^"]*)" should contain$/ do |actual_file, duration_replacement, text|
  actual = IO.read(actual_file)
  actual = replace_junit_duration(actual, duration_replacement) 
  actual = strip_ruby186_extra_trace(actual)
  actual.should == text
end

Then /^"([^"]*)" should match "(.+?)"$/ do |file, text|
  File.open(file, Cucumber.file_mode('r')).read.should =~ Regexp.new(text)
end

Then /^"([^"]*)" should have the same contents as "([^"]*)"$/ do |actual_file, expected_file|
  actual = IO.read(actual_file)
  actual = replace_duration(actual, '0m30.005s')
  # Comment out to replace expected file. Use with care!
  # File.open(expected_file, "w") {|io| io.write(actual)}
  actual.should == IO.read(expected_file)
end

Then /^STDERR should match$/ do |text|
  last_stderr.should =~ /#{text}/
end

Then /^STDERR should not match$/ do |text|
  last_stderr.should_not =~ /#{text}/
end

Then /^STDERR should be$/ do |text|
  last_stderr.should == text
end

Then /^STDERR should be empty$/ do
  last_stderr.should == ""
end

Then /^"([^"]*)" should exist$/ do |file|
  File.exists?(file).should be_true
  FileUtils.rm(file)
end

Then /^"([^"]*)" should not be required$/ do |file_name|
  last_stdout.should_not include("* #{file_name}")
end

Then /^"([^"]*)" should be required$/ do |file_name|
  last_stdout.should include("* #{file_name}")
end

Then /^exactly these files should be loaded:\s*(.*)$/ do |files|
  last_stdout.scan(/^  \* (.*\.rb)$/).flatten.should == files.split(/,\s+/)
end

Then /^exactly these features should be ran:\s*(.*)$/ do |files|
  last_stdout.scan(/^  \* (.*\.feature)$/).flatten.should == files.split(/,\s+/)
end

Then /^the (.*) profile should be used$/ do |profile|
  last_stdout.should =~ /Using the #{profile} profile/
end

Then /^print output$/ do
  puts last_stdout
end

Then /^the output should contain the following JSON:$/ do |json_string|
  JSON.parse(last_stdout).should == JSON.parse(json_string)
end
