When /^I filter notifications by likes$/ do
  step %(I follow "Liked" within "#notifications_container .list-group")
end

When /^I filter notifications by mentions$/ do
  step %(I follow "Mentioned" within "#notifications_container .list-group")
end

Then /^I should( not)? have activated notifications for the post( in the single post view)?$/ do |negate, spv|
  selector = spv ? "#single-post-moderation" : "#main_stream .stream-element"
  if negate
    expect(find(selector, match: :first)).to have_no_css(".destroy_participation", visible: false)
    expect(find(selector, match: :first)).to have_css(".create_participation", visible: false)
  else
    expect(find(selector, match: :first)).to have_css(".destroy_participation", visible: false)
    expect(find(selector, match: :first)).to have_no_css(".create_participation", visible: false)
  end
end
