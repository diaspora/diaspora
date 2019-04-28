# frozen_string_literal: true

When /^I (?:like|unlike) the post "([^"]*)" in the stream$/ do |post_text|
  like_stream_post(post_text)
end

Then /^"([^"]*)" should be post (\d+)$/ do |post_text, position|
  stream_element_numbers_content(position).should have_content(post_text)
end

When /^I toggle nsfw posts$/ do
  find(".toggle_nsfw_state", match: :first).click
end

When /^I toggle all nsfw posts$/ do
  all("a.toggle_nsfw_state").each &:click
end

Then /^I should have (\d+) nsfw posts$/ do |num_posts|
  page.should have_css(".nsfw-shield", count: num_posts.to_i)
end

When /^I prepare the deletion of the first post$/ do
  find(".stream .stream-element", match: :first).hover
  within(find(".stream .stream-element", match: :first)) do
    ctrl = find(".control-icons")
    ctrl.hover
    ctrl.find(".remove_post").click
  end
end

When /^I prepare hiding the first post$/ do
  find(".stream .stream-element", match: :first).hover
  within(find(".stream .stream-element", match: :first)) do
    ctrl = find(".control-icons")
    ctrl.hover
    ctrl.find(".hide_post").click
  end
end

When /^I click to delete the first post$/ do
  accept_alert do
    step "I prepare the deletion of the first post"
  end
  expect(find(".stream")).to have_no_css(".stream-element.loaded.deleting")
end

When /^I click to hide the first post$/ do
  accept_alert do
    step "I prepare hiding the first post"
  end
end

When /^I click to delete the first comment$/ do
  within("div.comment", match: :first) do
    find(".comment_delete", visible: false).click
  end
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
