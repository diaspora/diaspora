Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  Factory(:user, :username => username, :password => password,
          :password_confirmation => password, :getting_started => false)
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end

Given /^I have an aspect called "([^"]*)"$/ do |aspect_name|
  @me.aspects.create!(:name => aspect_name)
  @me.reload
end

Given /^I have one contact request$/ do
  other_user = make_user
  other_user.aspects.create!(:name => "meh")
  other_user.reload
      
  other_user.send_contact_request_to(@me.person, other_user.aspects.first)
  @me.reload
end

Then /^I should see (\d+) contact request(?:s)?$/ do |request_count|
  number_of_requests = evaluate_script("$('.person.request.ui-draggable').length")
  number_of_requests.should == request_count.to_i
end

Then /^I should see (\d+) contact(?:s)? in "([^"]*)"$/ do |contact_count, aspect_name|
  aspect = @me.reload.aspects.find_by_name(aspect_name)
  number_of_contacts = evaluate_script("$('li.person.ui-draggable[data-aspect_id=\"#{aspect.id}\"]').length")
  number_of_contacts.should == contact_count.to_i
end

When /^I drag the contact request to the "([^"]*)" aspect$/ do |aspect_name|
  aspect = @me.reload.aspects.find_by_name(aspect_name)
  aspect_div = find("ul.dropzone[data-aspect_id='#{aspect.id}']")
  request_li = find(".person.request.ui-draggable")
  request_li.drag_to(aspect_div)
end
