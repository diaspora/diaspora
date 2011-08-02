Given /^I have setup database cleaner to clean multiple databases using activerecord$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/datamapper_models"
  #
  # DatabaseCleaner[:datamapper, {:connection => :one} ].strategy = :truncation
  # DatabaseCleaner[:datamapper, {:connection => :two} ].strategy = :truncation
end

When /^I create a widget using activerecord$/ do
  ActiveRecordWidget.create!
end

Then /^I should see ([\d]+) widget using activerecord$/ do |widget_count|
  ActiveRecordWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using activerecord$/ do
  ActiveRecordWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using activerecord$/ do
  ActiveRecordWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using activerecord$/ do |widget_count|
  ActiveRecordWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using activerecord$/ do |widget_count|
  ActiveRecordWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
