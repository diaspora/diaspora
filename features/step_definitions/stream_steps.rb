Then /^I should see an image in the publisher$/ do
  photo_in_publisher.should be_present
end

Then /^I like the post "([^"]*)"$/ do |post_text|
  like_post(post_text)
end

Then /^"([^"]*)" should be post (\d+)$/ do |post_text, position|
  stream_element_numbers_content(position).text.should == post_text
end

When /^I toggle nsfw posts$/ do
  find(".toggle_nsfw_state", match: :first).click
end

Then /^I should have (\d+) nsfw posts$/ do |num_posts|
  page.should have_css(".nsfw-shield", count: num_posts.to_i)
end

When /^I click the show page link for "([^"]*)"$/ do |post_text|
  within(find_post_by_text(post_text)) do
    find("time").click
  end
end
