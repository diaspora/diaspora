# frozen_string_literal: true

When /^I focus the comment field$/ do
  focus_comment_box
end

Then /^the first comment field should be open/ do
  find("#main-stream .stream-element .new-comment").should be_visible
end

Then /^the first comment field should be closed$/ do
  page.should have_css(".stream-element .media")
  page.should_not have_selector("#main-stream .stream-element .new-comment", match: :first)
end

When /^I make a show page comment "([^"]*)"$/ do |comment_text|
  comment_on_show_page(comment_text)
end

Given /^"([^"]*)" has commented "([^"]*)" on "([^"]*)"$/ do |email, comment_text, post_text|
  user = User.find_by(email: email)
  post = StatusMessage.find_by(text: post_text)
  user.comment!(post, comment_text)
end

Given /^"([^"]*)" has commented mentioning "([^"]*)" on "([^"]*)"$/ do |email, mentionee_email, post_text|
  user = User.find_by(email: email)
  post = StatusMessage.find_by(text: post_text)
  user.comment!(post, text_mentioning(User.find_by(email: mentionee_email)))
end

Given /^"([^"]*)" has commented a lot on "([^"]*)"$/ do |email, post_text|
  user = User.find_by(email: email)
  post = StatusMessage.find_by(text: post_text)
  time = Time.zone.now - 1.year
  Timecop.freeze do
    (1..10).each do |n|
      Timecop.travel time += 1.day
      user.comment!(post, "Comment #{n}")
    end
  end
end

When /^I enter "([^"]*)" in the comment field$/ do |comment_text|
  find("textarea.comment-box.mention-textarea").native.send_keys(comment_text)
end

Then /^I like the comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  # Find like like-link within comment-block
  find(id: comment_guid).click_link("Like")
end

Then /^I should see a like within comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  block = find(id: comment_guid)
  expect(block).to have_css(".expand-likes")
end

When /^I expand likes within comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  find(id: comment_guid).click_link("1 Like")
  find(id: comment_guid).find(".entypo-heart").hover # unfocus avatar to get rid of tooltip
end

When /^I unlike comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  find(id: comment_guid).click_link("Unlike")
end

Then /^I should see a micro avatar within comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  block = find(id: comment_guid)
  expect(block).to have_css(".micro.avatar")
end

Then /^I should not see a micro avatar within comment "([^"]*)"$/ do |comment_text|
  comment_guid = Comment.find_by(text: comment_text).guid
  block = find(id: comment_guid)
  expect(block).not_to have_css(".micro.avatar")
end
