When /^I create a widget$/ do
  When "I create a widget using #{ENV['ORM'].downcase}"
end

Then /^I should see 1 widget$/ do
  Then "I should see 1 widget using #{ENV['ORM'].downcase}"
end

When /^I create a widget in one orm$/ do
  When "I create a widget using #{ENV['ORM'].downcase}"
end

When /^I create a widget in another orm$/ do
  When "I create a widget using #{ENV['ANOTHER_ORM'].downcase}"
end

Then /^I should see 1 widget in one orm$/ do
  When "I should see 1 widget using #{ENV['ORM'].downcase}"
end

Then /^I should see 1 widget in another orm$/ do
  When "I should see 1 widget using #{ENV['ANOTHER_ORM'].downcase}"
end

Then /^I should see 0 widget in another orm$/ do
  When "I should see 0 widget using #{ENV['ANOTHER_ORM'].downcase}"
end

Then /^I should see 0 widget in one orm$/ do
  When "I should see 0 widget using #{ENV['ORM'].downcase}"
end

When /^I create a widget in one db$/ do
  When "I create a widget in one db using #{ENV['ORM'].downcase}"
end

When /^I create a widget in another db$/ do
  When "I create a widget in another db using #{ENV['ORM'].downcase}"
end

Then /^I should see 1 widget in one db$/ do
  When "I should see 1 widget in one db using #{ENV['ORM'].downcase}"
end

Then /^I should see 1 widget in another db$/ do
  When "I should see 1 widget in another db using #{ENV['ORM'].downcase}"
end

Then /^I should see 0 widget in another db$/ do
  When "I should see 0 widget in another db using #{ENV['ORM'].downcase}"
end

Then /^I should see 0 widget in one db$/ do
  When "I should see 0 widget in one db using #{ENV['ORM'].downcase}"
end
