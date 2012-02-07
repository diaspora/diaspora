When /^I focus the comment field$/ do
  focus_comment_box
end

Then /^the first comment field should be open/ do
  find("#main_stream .stream_element .new_comment").should be_visible
end

Then /^the first comment field should be closed$/ do
  find("#main_stream .stream_element .new_comment").should_not be_visible
end


When /^I comment "([^"]*)" on "([^"]*)"$/ do |comment_text, post_text|
  comment_on_post(post_text, comment_text)
end
