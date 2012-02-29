Given /^I have posts for each type of template$/ do
  generate_post_of_each_template(@me)
end

Then /^I visit all of my posts$/ do
  @templates_seen = visit_posts_and_collect_template_names(@me)
end

When /^I should have seen all of my posts displayed with the correct template$/ do
    @templates_seen.should =~ TemplatePicker.jsonified_templates
end