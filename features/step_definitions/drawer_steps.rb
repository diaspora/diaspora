# frozen_string_literal: true

And /^I click on "([^"]*)" in the drawer$/ do |txt|
  within("#drawer") do
    find_link(txt).trigger "click"
  end
end
