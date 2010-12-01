Given /^this project is active project folder/ do
  @active_project_folder = File.expand_path(File.dirname(__FILE__) + "/../..")
end

Given /^env variable \$([\w_]+) set to "(.*)"/ do |env_var, value|
  ENV[env_var] = value
end

Given /I delete (folder|file) "([^\"]*)"/ do |type, folder|
  in_project_folder { FileUtils.rm_rf folder }
end

When /^I invoke "(.*)" generator with arguments "(.*)"$/ do |generator, arguments|
  @stdout = StringIO.new
  in_project_folder do
    if Object.const_defined?("APP_ROOT")
      APP_ROOT.replace(FileUtils.pwd)
    else 
      APP_ROOT = FileUtils.pwd
    end
    run_generator(generator, arguments.split(' '), SOURCES, :stdout => @stdout)
  end
  File.open(File.join(@tmp_root, "generator.out"), "w") do |f|
    @stdout.rewind
    f << @stdout.read
  end
end

When /^I run executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  in_project_folder do
    system "#{executable} #{arguments} > #{@stdout} 2> #{@stdout}"
  end
end

When /^I run project executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  in_project_folder do
    system "ruby #{executable} #{arguments} > #{@stdout} 2> #{@stdout}"
  end
end

When /^I run local executable "(.*)" with arguments "(.*)"/ do |executable, arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  executable = File.expand_path(File.join(File.dirname(__FILE__), "/../../bin", executable))
  in_project_folder do
    system "ruby #{executable} #{arguments} > #{@stdout} 2> #{@stdout}"
  end
end

When /^I invoke task "rake (.*)"/ do |task|
  @stdout = File.expand_path(File.join(@tmp_root, "rake.out"))
  @stderr = File.expand_path(File.join(@tmp_root, "rake.err"))
  in_project_folder do
    system "rake #{task} --trace > #{@stdout} 2> #{@stderr}"
  end
  File.read(@stderr).should_not =~ /rake aborted!/
end

Then /^folder "(.*)" (is|is not) created/ do |folder, is|
  in_project_folder do
    File.exists?(folder).should(is == 'is' ? be_true : be_false)
  end
end

Then /^file "(.*)" (is|is not) created/ do |file, is|
  in_project_folder do
    File.exists?(file).should(is == 'is' ? be_true : be_false)
  end
end

Then /^file with name matching "(.*)" is created/ do |pattern|
  in_project_folder do
    Dir[pattern].should_not be_empty
  end
end

Then /^file "(.*)" contents (does|does not) match \/(.*)\// do |file, does, regex|
  in_project_folder do
    actual_output = File.read(file)
    (does == 'does') ?
      actual_output.should(match(/#{regex}/)) :
      actual_output.should_not(match(/#{regex}/))
  end
end

Then /gem file "(.*)" and generated file "(.*)" should be the same/ do |gem_file, project_file|
  File.exists?(gem_file).should be_true
  File.exists?(project_file).should be_true
  gem_file_contents = File.read(File.dirname(__FILE__) + "/../../#{gem_file}")
  project_file_contents = File.read(File.join(@active_project_folder, project_file))
  project_file_contents.should == gem_file_contents
end

Then /^(does|does not) invoke generator "(.*)"$/ do |does_invoke, generator|
  actual_output = File.read(@stdout)
  does_invoke == "does" ?
    actual_output.should(match(/dependency\s+#{generator}/)) :
    actual_output.should_not(match(/dependency\s+#{generator}/))
end

Then /help options "(.*)" and "(.*)" are displayed/ do |opt1, opt2|
  actual_output = File.read(@stdout)
  actual_output.should match(/#{opt1}/)
  actual_output.should match(/#{opt2}/)
end

Then /^I should see "([^\"]*)"$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should contain(text)
end

Then /^I should not see "([^\"]*)"$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should_not contain(text)
end

Then /^I should see$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should contain(text)
end

Then /^I should not see$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should_not contain(text)
end

Then /^I should see exactly$/ do |text|
  actual_output = File.read(@stdout)
  actual_output.should == text
end

Then /^I should see all (\d+) tests pass/ do |expected_test_count|
  expected = %r{^#{expected_test_count} tests, \d+ assertions, 0 failures, 0 errors}
  actual_output = File.read(@stdout)
  actual_output.should match(expected)
end

Then /^I should see all (\d+) examples pass/ do |expected_test_count|
  expected = %r{^#{expected_test_count} examples?, 0 failures}
  actual_output = File.read(@stdout)
  actual_output.should match(expected)
end

Then /^yaml file "(.*)" contains (\{.*\})/ do |file, yaml|
  in_project_folder do
    yaml = eval yaml
    YAML.load(File.read(file)).should == yaml
  end
end

Then /^Rakefile can display tasks successfully/ do
  @stdout = File.expand_path(File.join(@tmp_root, "rakefile.out"))
  in_project_folder do
    system "rake -T > #{@stdout} 2> #{@stdout}"
  end
  actual_output = File.read(@stdout)
  actual_output.should match(/^rake\s+\w+\s+#\s.*/)
end

Then /^task "rake (.*)" is executed successfully/ do |task|
  @stdout.should_not be_nil
  actual_output = File.read(@stdout)
  actual_output.should_not match(/^Don't know how to build task '#{task}'/)
  actual_output.should_not match(/Error/i)
end

Then /^gem spec key "(.*)" contains \/(.*)\// do |key, regex|
  in_project_folder do
    gem_file = Dir["pkg/*.gem"].first
    gem_spec = Gem::Specification.from_yaml(`gem spec #{gem_file}`)
    spec_value = gem_spec.send(key.to_sym)
    spec_value.to_s.should match(/#{regex}/)
  end
end
