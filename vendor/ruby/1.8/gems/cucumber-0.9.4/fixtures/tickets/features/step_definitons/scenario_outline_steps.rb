Given /^there are (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine = EattingMachine.new(fruit, count)
end

Given "the belly space is < 12 and > 6" do
end

Given "I have the following fruits in my pantry" do |pantry_table|
  @pantry = Pantry.new
  pantry_table.hashes.each do |item|
    @pantry.add(item['name'].downcase, item['quantity'])
  end
end

Given "my shopping list" do |list|
  @shopping_list = list
end

When /^I eat (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine.eat(count)
  @eattingMachine.belly_count = count.to_i
end

When /^I eat (\d+) (\w+) from the pantry$/ do |count, fruit|
  @pantry.remove(fruit, count.to_i)
end

Then /^I should have (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine.fruit_total.should == count.to_i
end

Then /^I should have (\d+) (\w+) in my belly$/ do |count, fruit|
  @eattingMachine.belly_count.should == count.to_i
end

Then /^I should have (\d+) (\w+) in the pantry$/ do |count, fruit|
  @pantry.count(fruit).should == count.to_i
end

Then /^my shopping list should equal$/ do |list|
  @shopping_list.should == list
end