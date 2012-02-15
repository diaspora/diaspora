Then /^I should see an image in the publisher$/ do
  photo_in_publisher.should be_present
end

Then /^I like the post "([^"]*)"$/ do |post_text|
  like_post(post_text)
end

Then /^"([^"]*)" should be post (\d+)$/ do |post_text, position|
  find(".stream_element:nth-child(#{position}) .post-content").text.should == post_text
end

When /^I toggle nsfw posts$/ do
  find(".toggle_nsfw_state").click
end

Then /^I should have (\d+) nsfw posts$/ do |num_posts|
  all(".nsfw-shield").size.should == num_posts.to_i
end