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
