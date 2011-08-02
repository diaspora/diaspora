When /^I setup load path to local code$/ do
  project_lib_path = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  in_project_folder do
    force_local_lib_override(:target => 'features/step_definitions/culerity_steps.rb')
  end
end

