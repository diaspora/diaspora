Then /^the post should be collapsed$/ do
  first_post_collapsed?
end

Then /^the post should be expanded$/ do
  first_post_expanded?
end

Then /^I should see an uploaded image within the photo drop zone$/ do
  find("#photodropzone img")["src"].should include("uploads/images")
end

Then /^I should not see an uploaded image within the photo drop zone$/ do
  page.should_not have_css "#photodropzone img"
end

Then /^I should not see any posts in my stream$/ do
  page.assert_selector("#paginate .loader", visible: :hidden)
  page.assert_selector(".stream_element", count: 0)
end

Then /^I should not be able to submit the publisher$/ do
  expect(publisher_submittable?).to be false
end

Given /^"([^"]*)" has a public post with text "([^"]*)"$/ do |email, text|
  user = User.find_by_email(email)
  user.post(:status_message, :text => text, :public => true, :to => user.aspect_ids)
end

Given /^there are (\d+) public posts from "([^"]*)"$/ do |n_posts, email|
  user = User.find_by_email(email)
  (1..n_posts.to_i).each do |n|
    user.post(:status_message, text: "post nr. #{n}", public: true, to: user.aspect_ids)
  end
end

Given /^"([^"]*)" has a non public post with text "([^"]*)"$/ do |email, text|
  user = User.find_by_email(email)
  user.post(:status_message, :text => text, :public => false, :to => user.aspect_ids)
end

And /^the post with text "([^"]*)" is reshared by "([^"]*)"$/ do |text, email|
  user = User.find_by_email(email)
  root = Post.find_by_text(text)
  user.post(:reshare, :root_guid => root.guid, :public => true, :to => user.aspect_ids)
end

And /^I submit the publisher$/ do
  submit_publisher
end

When /^I click on the first block button/ do
  find(".stream_element", match: :first).hover
  find(".block_user").click
end

When /^I click on the profile block button/ do
  find("#profile_buttons .block_user").click
end

When /^I expand the post$/ do
  expand_first_post
end

When /^I click the publisher and post "([^"]*)"$/ do |text|
  click_and_post(text)
end

When /^I post an extremely long status message$/ do
  click_and_post("I am a very interesting message " * 64)
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

When /^I append "([^"]*)" to the mobile publisher$/ do |text|
  append_to_publisher(text, '#status_message_text')
end

When /^I attach "([^"]*)" to the publisher$/ do |path|
  upload_file_with_publisher(path)
end

When /^I open the show page of the "([^"]*)" post$/ do |post_text|
  visit post_path_by_content(post_text)
end

When /^I select "([^"]*)" on the aspect dropdown$/ do |text|
  page.execute_script(
    "$('#publisher .dropdown .dropdown_list, #publisher .aspect_dropdown .dropdown-menu')
      .find('li').each(function(i,el){
      var elem = $(el);
      if ('" + text + "' == $.trim(elem.text()) ) {
        elem.click();
      }});")
end
