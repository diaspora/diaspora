# frozen_string_literal: true

Then /^I expand the publisher$/ do
  click_publisher
end

And /^I close the publisher$/ do
  find("#publisher .md-cancel").click
end

Then /^the publisher should be expanded$/ do
  find("#publisher")["class"].should_not include("closed")
end

When /^I click to delete the first uploaded photo$/ do
  page.execute_script("$('#photodropzone .x').css('display', 'block');")
  image_count = all(".publisher_photo img", wait: false).count
  find("#photodropzone .x", match: :first).trigger "click"
  page.assert_selector(".publisher_photo img", count: image_count - 1)
end

Then /^I should see an uploaded image within the photo drop zone$/ do
  expect(find("#photodropzone img")["src"]).to include("uploads/images")
end

Then /^I should not see an uploaded image within the photo drop zone$/ do
  page.should_not have_css "#photodropzone img"
end

Then /^I should not be able to submit the publisher$/ do
  expect(publisher_submittable?).to be false
end

Then /^I should see "([^"]*)" in the publisher$/ do |text|
  expect(page).to have_field("status_message[text]", with: text)
end

When /^I write the status message "([^"]*)"$/ do |text|
  write_in_publisher(text)
end

When /^I insert an extremely long status message$/ do
  write_in_publisher("I am a very interesting message " * 64)
end

When /^I append "([^"]*)" to the publisher$/ do |text|
  append_to_publisher(text)
end

When /^I attach "([^"]*)" to the publisher$/ do |path|
  upload_file_with_publisher(path)
end

And /^I submit the publisher$/ do
  submit_publisher
end

When /^I click the publisher and post "([^"]*)"$/ do |text|
  click_and_post(text)
end

When /^I post an extremely long status message$/ do
  click_and_post("I am a very interesting message " * 64)
end

When /^I select "([^"]*)" on the aspect dropdown$/ do |text|
  page.execute_script(
    "$('#publisher .dropdown .dropdown_list, #publisher .aspect-dropdown .dropdown-menu')
      .find('li').each(function(i,el){
      var elem = $(el);
      if ('" + text + "' == $.trim(elem.text()) ) {
        elem.click();
      }});"
  )
end
