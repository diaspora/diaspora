When /^I trumpet$/ do
  visit new_post_path
end

When /^I write "([^"]*)"$/ do |text|
  fill_in :text, :with => text
end
