# frozen_string_literal: true

When /^(?:|I )click on "([^"]*)" navbar title$/ do |title|
  with_scope(".info-bar") do
    find("h5", text: title).click
  end
end

Given /^I have configured a Bitcoin address$/ do
  AppConfig.settings.bitcoin_address = "AAAAAA"
end

Then /^I should see the Bitcoin address$/ do
  find("#bitcoin_address")["value"].should == "AAAAAA"
end

Given /^I have configured a Liberapay username$/ do
  AppConfig.settings.liberapay_username = "BBBBBB"
end

Then /^I should see the Liberapay donate button$/ do
  find("#liberapay-button")["href"].should == "https://liberapay.com/BBBBBB/donate"
end
