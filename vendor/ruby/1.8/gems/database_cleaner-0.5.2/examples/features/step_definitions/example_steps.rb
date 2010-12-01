When /^I create a widget$/ do
  Widget.create!
end

Then /^I should see 1 widget$/ do
  Widget.count.should == 1
end

