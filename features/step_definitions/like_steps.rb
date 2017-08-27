# frozen_string_literal: true

Given /^"([^"]*)" has liked the post "([^"]*)"$/ do |email, post_text|
  user = User.find_by(email: email)
  post = StatusMessage.find_by(text: post_text)
  user.like!(post)
end
