# frozen_string_literal: true

Then /^the post should be collapsed$/ do
  first_post_collapsed?
end

Then /^the post should be expanded$/ do
  first_post_expanded?
end

Then /^I should see an uploaded image within the photo drop zone$/ do
  expect(find("#photodropzone img")["src"]).to include("uploads/images")
end

Then /^I should not see an uploaded image within the photo drop zone$/ do
  page.should_not have_css "#photodropzone img"
end

Then /^I should not see any posts in my stream$/ do
  expect(page).not_to have_selector("#paginate .loader")
  expect(page).not_to have_selector(".stream-element .media")
  expect(page).to have_selector(".stream-element .no-posts-info")
end

Then /^I should not see any picture in my stream$/ do
  expect(page).to have_selector(".photo_area img", count: 0)
end

Then /^I should see (\d+) pictures in my stream$/ do |count|
  expect(page).to have_selector(".photo_area img", count: count)
end

Then /^I should not be able to submit the publisher$/ do
  expect(publisher_submittable?).to be false
end

Then /^I should see "([^"]*)" in the publisher$/ do |text|
  expect(page).to have_field("status_message[text]", with: text)
end

Given /^I have a limited post with text "([^\"]*)" in the aspect "([^"]*)"$/ do |text, aspect_name|
  @me.post :status_message, text: text, to: @me.aspects.where(name: aspect_name).first.id
end

Given /^"([^"]*)" has a public post with text "([^"]*)"$/ do |email, text|
  user = User.find_by_email(email)
  user.post(:status_message, :text => text, :public => true, :to => user.aspect_ids)
end

Given /^"([^"]*)" has a public post with text "([^"]*)" and a poll$/ do |email, text|
  user = User.find_by(email: email)
  post = user.post(:status_message, text: text, public: true, to: user.aspect_ids)
  FactoryGirl.create(:poll, status_message: post)
end

Given /^"([^"]*)" has a public post with text "([^"]*)" and a location$/ do |email, text|
  user = User.find_by(email: email)
  post = user.post(:status_message, text: text, public: true, to: user.aspect_ids)
  FactoryGirl.create(:location, status_message: post)
end

Given /^"([^"]*)" has a public post with text "([^"]*)" and a picture/ do |email, text|
  user = User.find_by(email: email)
  post = user.post(:status_message, text: text, public: true, to: user.aspect_ids)
  FactoryGirl.create(:photo, status_message: post)
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
  find(".stream-element", match: :first).hover
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

When /^I attach "([^"]*)" to the publisher$/ do |path|
  upload_file_with_publisher(path)
end

When /^I open the show page of the "([^"]*)" post$/ do |post_text|
  visit post_path_by_content(post_text)
end

When /^I select "([^"]*)" on the aspect dropdown$/ do |text|
  page.execute_script(
    "$('#publisher .dropdown .dropdown_list, #publisher .aspect-dropdown .dropdown-menu')
      .find('li').each(function(i,el){
      var elem = $(el);
      if ('" + text + "' == $.trim(elem.text()) ) {
        elem.click();
      }});")
end
