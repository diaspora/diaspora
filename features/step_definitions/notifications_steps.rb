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

And "I wait for notifications to load" do
  page.should_not have_selector(".loading")
end

And /^I scroll down on the notifications dropdown$/ do
  page.execute_script("$('.notifications').scrollTop(350)")
end

Then /^I should have scrolled down on the notification dropdown$/ do
  expect(page.evaluate_script("$('.notifications').scrollTop()")).to be > 0
end

Then /^the notification dropdown should be visible$/ do
  expect(find(:css, "#notification-dropdown")).to be_visible
end

Then /^the notification dropdown scrollbar should be visible$/ do
  find(:css, ".ps-active-y").should be_visible
end

Then /^there should be (\d+) notifications loaded$/ do |n|
  result = page.evaluate_script("$('.media.stream-element').length")
  result.should == n.to_i
end

And /^I activate the first hovercard after loading the notifications page$/ do
  page.should have_css '.notifications .hovercardable'
  first('.notifications .hovercardable').hover
end
