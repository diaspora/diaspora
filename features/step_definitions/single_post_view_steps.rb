# frozen_string_literal: true

And /^I click to hide the post/ do
  find('.hide_post').click
end

And /^I click to block the user/ do
  find('.block_user').click
end

And /^I click to report the post/ do
  find('.post_report').click
end

And /^I click to delete the post/ do
  find('.remove_post').click
end

And /^I click to (?:like|unlike) the post/ do
  like_show_page_post
end

