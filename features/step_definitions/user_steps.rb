Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  Factory(:user, :username => username, :password => password,
          :password_confirmation => password, :getting_started => false)
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end