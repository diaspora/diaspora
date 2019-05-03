# frozen_string_literal: true

Then /^the post should be collapsed$/ do
  first_post_collapsed?
end

Then /^the post should be expanded$/ do
  first_post_expanded?
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

When /^I open the show page of the "([^"]*)" post$/ do |post_text|
  visit post_path_by_content(post_text)
end

Then /^I should see an image attached to the post$/ do
  step %(I should see a "img" within ".stream-element div.photo-attachments")
end

Then /^I press the attached image$/ do
  step %(I press the 1st "img" within ".stream-element div.photo-attachments")
end
