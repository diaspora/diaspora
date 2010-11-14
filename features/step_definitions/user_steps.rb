Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  Factory(:user, :username => username, :password => password,
          :password_confirmation => password, :getting_started => false)
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end

Given /^I have one contact request$/ do
  other_user = make_user
  other_user.aspects.create!(:name => "meh")
  other_user.reload
      
  other_user.send_contact_request_to(@me.person, other_user.aspects.first)
  @me.reload
end

Then /^I should see (\d+) contact request(?:s)?$/ do |request_count|
  pending
  # person.request.ui-draggable.count.should == request_count - but how do I count things in CSS?
end

Then /^I should see (\d+) contact(?:s)? in "([^"]*)"$/ do |request_count, aspect_name|
  pending # express the regexp above with the code you wish you had
end

When /^I drag the contact request to the "([^"]*)" aspect$/ do |aspect_name|
  pending # express the regexp above with the code you wish you had
end
