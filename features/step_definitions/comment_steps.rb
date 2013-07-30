When /^I focus the comment field$/ do
  focus_comment_box
end

Then /^the first comment field should be open/ do
  find("#main_stream .stream_element .new_comment").should be_visible
end

Then /^the first comment field should be closed$/ do
  page.should have_css(".stream_element")
  find("#main_stream .stream_element .new_comment", match: :first, visible: false).should_not be_visible
end

When /^I comment "([^"]*)" on "([^"]*)"$/ do |comment_text, post_text|
  comment_on_post(post_text, comment_text)
end

When /^I make a show page comment "([^"]*)"$/ do |comment_text|
  comment_on_show_page(comment_text)
end
