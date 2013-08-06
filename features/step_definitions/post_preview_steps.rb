Then /^the first post should be a preview$/ do
  find(".post_preview .post-content").text.should == first_post_text
end

Then /^the preview should not be collapsed$/ do
  find(".post_preview").should_not have_selector('.collapsed')
  find(".post_preview").should have_selector('.opened')
end

