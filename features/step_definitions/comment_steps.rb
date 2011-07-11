When /^I focus the comment field$/ do
  find("a.focus_comment_textarea").click
end

When /^I open the comment box$/ do
  page.evaluate_script('Stream.focusNewComment($(".stream_element"), {preventDefault: function(){}})')
end

Then /^the first comment field should be open/ do
  find("#main_stream .stream_element .new_comment").should be_visible
end

Then /^the first comment field should be closed$/ do
  find("#main_stream .stream_element .new_comment").should_not be_visible
end
