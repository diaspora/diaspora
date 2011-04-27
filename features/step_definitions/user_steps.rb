Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  @me ||= Factory(:user, :username => username, :password => password,
                  :password_confirmation => password, :getting_started => false)
  @me.aspects.create(:name => "Besties")
  @me.aspects.create(:name => "Unicorns")
end

Given /^that I am a rock star$/ do
  Given('a user with username "awesome" and password "totallyawesome"')
end

Given /^a user with email "([^\"]*)"$/ do |email|
  user = Factory(:user, :email => email, :password => 'password',
                 :password_confirmation => 'password', :getting_started => false)
  user.aspects.create(:name => "Besties")
  user.aspects.create(:name => "Unicorns")
end

Given /^a user with username "([^\"]*)"$/ do |username|
  user = Factory(:user, :email => username + "@" + username + '.' + username, :username => username,
                 :password => 'password', :password_confirmation => 'password', :getting_started => false)
  user.aspects.create(:name => "Besties")
  user.aspects.create(:name => "Unicorns")
end

Given /^a user named "([^\"]*)" with email "([^\"]*)"$/ do |name, email|
  first, last = name.split
  username = "#{first}_#{last}" if first
  user = Factory(:user, :email => email, :password => 'password', :username => "#{first}_#{last}",
                 :password_confirmation => 'password', :getting_started => false)
  user.profile.update_attributes(:first_name => first, :last_name => last) if first
  user.aspects.create(:name => "Besties")
  user.aspects.create(:name => "Unicorns")
end

Given /^I have been invited by an admin$/ do
  @me = Invitation.create_invitee(:service => 'email', :identifier => "new_invitee@example.com")
end

Given /^I have been invited by a user$/ do
  @inviter = Factory(:user)
  aspect = @inviter.aspects.create(:name => "Rocket Scientists")
  @me = @inviter.invite_user(aspect.id, 'email', "new_invitee@example.com", "Hey, tell me about your rockets!")
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end

Given /^I have an aspect called "([^\"]*)"$/ do |aspect_name|
  @me.aspects.create!(:name => aspect_name)
  @me.reload
end

When /^I have user with username "([^"]*)" in an aspect called "([^"]*)"$/ do |username, aspect|
  user = User.find_by_username(username)
  contact = @me.reload.contact_for(user.person)
  contact.aspects << @me.aspects.find_by_name(aspect)
end

Given /^I have one contact request$/ do
  other_user = Factory(:user)
  other_aspect = other_user.aspects.create!(:name => "meh")
  other_user.send_contact_request_to(@me.person, other_aspect)

  other_user.reload
  other_aspect.reload
  @me.reload
end

Then /^I should see (\d+) contact request(?:s)?$/ do |request_count|
  wait_until do
    number_of_requests = evaluate_script("$('.person.request.ui-draggable').length")
    number_of_requests == request_count.to_i
  end
end

Then /^I should see (\d+) contact(?:s)? in "([^\"]*)"$/ do |contact_count, aspect_name|
  aspect = @me.reload.aspects.find_by_name(aspect_name)
  number_of_contacts = evaluate_script(
    "$('ul.dropzone.ui-droppable[data-aspect_id=\"#{aspect.id}\"]').children('li.person').length")
  number_of_contacts.should == contact_count.to_i
end

Then /^I should see no contact(?:s)? in "([^\"]*)"$/ do |aspect_name|
  aspect = @me.reload.aspects.find_by_name(aspect_name)
  number_of_contacts = evaluate_script(
    "$('ul.dropzone.ui-droppable[data-aspect_id=\"#{aspect.id}\"]').children('li.person').length")
  number_of_contacts.should == 0
end

When /^I drag the contact request to the "([^\"]*)" aspect$/ do |aspect_name|
  Given "I have turned off jQuery effects"
  aspect = @me.reload.aspects.find_by_name(aspect_name)
  aspect_div = find("ul.dropzone[data-aspect_id='#{aspect.id}']")
  request_li = find(".person.request.ui-draggable")
  request_li.drag_to(aspect_div)
end

When /^I click "X" on the contact request$/ do
  evaluate_script <<-JS
    window.confirm = function() { return true; };
    $(".person.request.ui-draggable .delete").hover().click();
  JS
end

When /^I click on the contact request$/ do
  find(".person.request.ui-draggable a").click
end

Given /^I have no open aspects saved$/ do
  @me.aspects.update_all(:open => false)
end

Then /^aspect "([^"]*)" should (not )?be selected$/ do |aspect_name, not_selected|
  link_is_selected = evaluate_script("$('a:contains(\"#{aspect_name}\")').parent('li').hasClass('selected');")
  expected_value = !not_selected
  link_is_selected.should == expected_value
end

Given /^a user with email "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:email => arg1).first
  user2 = User.where(:email => arg2).first
  connect_users(user1, user1.aspects.first, user2, user2.aspects.first)
end

Given /^a user with username "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:username => arg1).first
  user2 = User.where(:username => arg2).first
  connect_users(user1, user1.aspects.first, user2, user2.aspects.first)
end

Given /^there is a user "([^\"]*)" who's tagged "([^\"]*)"$/ do |full_name, tag|
  username = full_name.gsub(/\W/, "").underscore
  Given "a user named \"#{full_name}\" with email \"#{username}@example.com\""
  user = User.find_by_username(username)
  user.profile.tag_string = tag
  user.profile.build_tags
  user.profile.save!
end

Given /^many posts from bob and alice$/ do
  alice = Factory(:user_with_aspect, :username => 'alice', :email => 'alice@alice.alice', :password => 'password', :getting_started => false)
  bob = Factory(:user_with_aspect, :username => 'bob', :email => 'bob@bob.bob', :password => 'password', :getting_started => false)
  connect_users_with_aspects(alice, bob)
  time_interval = 1000
  (1..20).each do |n|
    [alice, bob].each do |u|
      post = u.post :status_message, :text => "#{u.username} - #{n} - #seeded", :to => u.aspects.first.id
      post.created_at = post.created_at - time_interval
      post.updated_at = post.updated_at - time_interval
      post.save
      time_interval += 1000
    end
  end
end
