When /^I visit the mobile aspects page$/ do
  visit('/aspects.mobile')
end

When /^I visit the mobile home page$/ do
  visit('/users/sign_in.mobile')
end

Given /^I publisher mobile page$/ do
  visit('/status_messages/new.mobile')
end

When /^I visit the mobile stream page$/ do
  visit('/stream.mobile')
end

When /^I toggle the mobile view$/ do
  visit('/mobile/toggle')
end

When /^I visit the mobile getting started page$/ do
  visit('/getting_started.mobile')
end

When /^I visit the mobile search page$/ do
  visit('/people.mobile')
end

When /^I open the drawer$/ do
  find('#menu_badge').click
end
