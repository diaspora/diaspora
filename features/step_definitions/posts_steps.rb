Then /^the post "([^"]*)" should be marked nsfw$/ do |text|
  assert_nsfw(text)
end

Then /^the post should be collapsed$/ do
  first_post_collapsed?
end

Then /^the post should be expanded$/ do
  first_post_expanded?
end

Then /^I should see an uploaded image within the photo drop zone$/ do
  find("#photodropzone img", visible: false)["src"].should include("uploads/images")
end

Then /^I should not see an uploaded image within the photo drop zone$/ do
  page.should_not have_css "#photodropzone img"
end

Then /^I should not see any posts in my stream$/ do
  all(".stream_element").should be_empty
end

Given /^"([^"]*)" has a public post with text "([^"]*)"$/ do |email, text|
  user = User.find_by_email(email)
  user.post(:status_message, :text => text, :public => true, :to => user.aspects)
end

Given /^"([^"]*)" has a non public post with text "([^"]*)"$/ do |email, text|
  user = User.find_by_email(email)
  user.post(:status_message, :text => text, :public => false, :to => user.aspects)
end

And /^the post with text "([^"]*)" is reshared by "([^"]*)"$/ do |text, email|
  user = User.find_by_email(email)
  root = Post.find_by_text(text)
  user.post(:reshare, :root_guid => root.guid, :public => true, :to => user.aspects)
end

When /^The user deletes their first post$/ do
  @me.posts.first.destroy
end

When /^I click on the first block button/ do
  find(".block_user", visible: false).click
end

When /^I expand the post$/ do
  expand_first_post
end

Then /^I should see "([^"]*)" as the first post in my stream$/ do |text|
  first_post_text.should include(text)
end

When /^I post "([^"]*)"$/ do |text|
  click_and_post(text)
end

When /^I click the publisher and post "([^"]*)"$/ do |text|
  click_and_post(text)
end

When /^I post an extremely long status message$/ do
  click_and_post("I am a very interesting message " * 64)
end

When /^I insert an extremely long status message$/ do
  fill_in 'status_message_fake_text', :with => "I am a very interesting message " * 64
end

When /^I open the show page of the "([^"]*)" post$/ do |post_text|
  visit post_path_by_content(post_text)
end

When /^I select "([^"]*)" on the aspect dropdown$/ do |text|
  page.execute_script(
    "$('#publisher .dropdown .dropdown_list')
      .find('li').each(function(i,el){
      var elem = $(el);
      if ('" + text + "' == $.trim(elem.text()) ) {
        elem.click();
      }});")
end
