When /^I add "([^"]+)" from this project as a dependency$/ do |gem_name|
  append_to_file('Gemfile', %{gem "#{gem_name}", :path => "#{PROJECT_ROOT}"})
end
