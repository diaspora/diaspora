Then /^"([^"]*)" should be frame (\d+)$/ do |post_text, position|
    frame_numbers_content(position).find(".text-content").text.should == post_text
end

When /^I click the "([^"]*)" stream frame$/ do |post_text|
  within "#stream-content" do
    find_frame_by_text(post_text).find(".content").click
  end
end

Then /^"([^"]*)" should be a comment for "([^"]*)"$/ do |comment_text, post_text|
  post = find_frame_by_text(post_text)
  post.find(".comment:contains('#{comment_text}')").should be_present
end

When /^I click into the "([^"]*)" stream frame$/ do |post_text|
  find("#stream-content .content:contains('#{post_text}') .permalink").click
  #within "#stream-content" do
  #  post = find_frame_by_text(post_text)
  #  link = post.find(".permalink")
  #  link.click
  #end
end