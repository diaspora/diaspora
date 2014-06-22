When /^I focus the comment field$/ do
  focus_comment_box
end

Then /^the first comment field should be open/ do
  find("#main_stream .stream_element .new_comment").should be_visible
end

Then /^the first comment field should be closed$/ do
  page.should have_css(".stream_element")
  page.should_not have_selector("#main_stream .stream_element .new_comment", match: :first)
end

When /^I comment "([^"]*)" on "([^"]*)"$/ do |comment_text, post_text|
  comment_on_post(post_text, comment_text)
end

When /^I make a show page comment "([^"]*)"$/ do |comment_text|
  comment_on_show_page(comment_text)
end

When /^I comment a lot on "([^"]*)"$/ do |post_text|
  within_post(post_text) do
    (1..10).each do |n|
      focus_comment_box
      make_comment(n)
    end
  end
end

