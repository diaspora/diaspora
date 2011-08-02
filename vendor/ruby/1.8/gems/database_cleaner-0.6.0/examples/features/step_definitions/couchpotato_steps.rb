Given /^I have setup database cleaner to clean multiple databases using couchpotato$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/couchpotato_models"
  #
  # DatabaseCleaner[:couchpotato, {:connection => :one} ].strategy = :truncation
  # DatabaseCleaner[:couchpotato, {:connection => :two} ].strategy = :truncation
end

When /^I create a widget using couchpotato$/ do
  CouchPotatoWidget.create!
end

Then /^I should see ([\d]+) widget using couchpotato$/ do |widget_count|
  CouchPotatoWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using couchpotato$/ do
  CouchPotatoWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using couchpotato$/ do
  CouchPotatoWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using couchpotato$/ do |widget_count|
  CouchPotatoWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using couchpotato$/ do |widget_count|
  CouchPotatoWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
