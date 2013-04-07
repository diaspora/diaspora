Then /^the first post should be a preview$/ do
  find(".post_preview .post-content").text.should == first_post_text
end
