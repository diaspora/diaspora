# frozen_string_literal: true

When /^I toggle the mobile view$/ do
  visit("/mobile/toggle")
end

Given /^I visit the mobile publisher page$/ do
  visit("/status_messages/new.mobile")
end

When /^I visit the mobile search page$/ do
  visit("/people.mobile")
end

When /^I open the drawer$/ do
  find("#menu-badge").click
  expect(page).to have_css("#app.draw")
end

Then /^the aspect dropdown within "([^"]*)" should be labeled "([^"]*)"/ do |selector, label|
  within(selector) do
    current_scope.should have_no_css("option.list_cover", text: "updating...")
    current_scope.should have_css("option.list_cover", text: label)
  end
end
