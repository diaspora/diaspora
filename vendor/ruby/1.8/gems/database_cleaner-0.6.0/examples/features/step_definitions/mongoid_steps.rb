When /^I create a widget using mongoid$/ do
  MongoidWidget.create!( :id => rand(1000)+1000)
end

Then /^I should see ([\d]+) widget using mongoid$/ do |widget_count|
  MongoidWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using mongoid$/ do
  MongoidWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using mongoid$/ do
  MongoidWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using mongoid$/ do |widget_count|
  MongoidWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using mongoid$/ do |widget_count|
  MongoidWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
