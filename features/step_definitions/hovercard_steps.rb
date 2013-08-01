When(/^I activate the first hovercard$/) do
  page.execute_script("$('.hovercardable').first().trigger('mouseenter');")
end

Then(/^I should see a hovercard$/) do
  page.should have_css '#hovercard'
end

When(/^I deactivate the first hovercard$/) do
  page.execute_script("$('.hovercardable').first().trigger('mouseleave');")
end

Then(/^I should not see a hovercard$/) do
  page.should_not have_css '#hovercard'
end
