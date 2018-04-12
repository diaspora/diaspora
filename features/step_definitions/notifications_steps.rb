# frozen_string_literal: true

When "I filter notifications by likes" do
  step %(I follow "Liked" within "#notifications_container .list-group")
end

When "I filter notifications by mentions" do
  step %(I follow "Mentioned in post" within "#notifications_container .list-group")
end

Then /^I should( not)? have activated notifications for the post( in the single post view)?$/ do |negate, spv|
  selector = spv ? "#single-post-moderation" : "#main-stream .stream-element"
  if negate
    expect(find(selector, match: :first)).to have_no_css(".destroy_participation", visible: false)
    expect(find(selector, match: :first)).to have_css(".create_participation", visible: false)
  else
    expect(find(selector, match: :first)).to have_css(".destroy_participation", visible: false)
    expect(find(selector, match: :first)).to have_no_css(".create_participation", visible: false)
  end
end

And "I wait for notifications to load" do
  expect(find("#notification-dropdown")).to have_no_css(".loading")
end

And "I scroll down on the notifications dropdown" do
  page.execute_script("$('.notifications').scrollTop(350)")
end

Then "the notification dropdown should be visible" do
  expect(find(:css, "#notification-dropdown")).to be_visible
end

Then "the notification dropdown scrollbar should be visible" do
  expect(find(:css, ".ps--active-y")).to be_visible
end

Then /^there should be (\d+) notifications loaded$/ do |n|
  expect(page).to have_css("#notification-dropdown .media.stream-element", count: n)
end

When "I activate the first hovercard in the notification dropdown" do
  expect(page).to have_css("#notification-dropdown .hovercardable")
  first("#notification-dropdown .hovercardable").hover
end
