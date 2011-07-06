When /^I focus the comment field$/ do
  find("a.focus_comment_textarea").click
end

When /^I open the comment box$/ do
  page.evaluate_script('Stream.focusNewComment($(".stream_element"), {preventDefault: function(){}})')
end

Then /^the first comment field should be open/ do
  css_query = "$('#main_stream .stream_element:first ul.comments:visible')"
  page.evaluate_script("#{css_query}.length").should == 1
end

Then /^the first comment field should be closed$/ do
  css_query = "$('#main_stream .stream_element:first ul.comments:hidden')"
  page.evaluate_script("#{css_query}.length").should == 1
end
