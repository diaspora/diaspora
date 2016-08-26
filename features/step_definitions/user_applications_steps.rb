Then /^I should see (\d+) authorized applications$/ do |num|
  expect(page).to have_selector(".applications-page", count: 1)
  expect(page).to have_selector(".authorized-application", count: num.to_i)
end

Then /^I should see (\d+) authorized applications with no provided image$/ do |num|
  expect(page).to have_selector(".application-img > .entypo-browser", count: num.to_i)
end

Then /^I should see (\d+) authorized applications with an image$/ do |num|
  expect(page).to have_selector(".application-img > .img-responsive", count: num.to_i)
end

When /^I revoke the first authorization$/ do
  find(".app-revoke", match: :first).click
end
