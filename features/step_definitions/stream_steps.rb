Then /^I should see an image in the publisher$/ do
  photo_in_publisher.should be_present
end

Then /^I pin the post "([^"]*)"$/ do |post_text|
  pin_post(post_text)
end

Then /^"([^"]*)" should be post (\d+)$/ do |post_text, position|
  find(".stream_element:nth-child(#{position}) .post-content").text.should == post_text
end
