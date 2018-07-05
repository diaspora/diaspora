# frozen_string_literal: true

When /^I open an external link to the first post of "([^"]*)"$/ do |email|
  user = User.find_by(email: email)
  post = user.posts.first
  visit(link_path(q: "web+diaspora://#{user.diaspora_handle}/post/#{post.guid}"))
end
