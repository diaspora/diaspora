Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  @me ||= Factory(:user, :username => username, :password => password,
                  :password_confirmation => password, :getting_started => false)
  @me.aspects.create(:name => "Besties")
  @me.aspects.create(:name => "Unicorns")
  @me.reload
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


Given /^I have one follower$/ do
  other_user = Factory(:user)
  other_aspect = other_user.aspects.create!(:name => "meh")
  other_user.share_with(@me.person, other_aspect)

  other_user.reload
  other_aspect.reload
  @me.reload
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

Given /^many posts from alice for bob$/ do
  alice = Factory(:user_with_aspect, :username => 'alice', :email => 'alice@alice.alice', :password => 'password', :getting_started => false)
  bob = Factory(:user_with_aspect, :username => 'bob', :email => 'bob@bob.bob', :password => 'password', :getting_started => false)
  connect_users_with_aspects(alice, bob)
  time_fulcrum = Time.now - 40000
  time_interval = 1000
  (1..40).each do |n|
    post = alice.post :status_message, :text => "#{alice.username} - #{n} - #seeded", :to => alice.aspects.first.id
    post.created_at = time_fulcrum - time_interval
    post.updated_at = time_fulcrum + time_interval
    post.save
    time_interval += 1000
  end
end


Then /^I should have (\d) contacts? in "([^"]*)"$/ do |n_contacts, aspect_name|
  @me.aspects.where(:name => aspect_name).first.contacts.count.should == n_contacts.to_i
end

When /^I (add|remove|toggle) the person (to|from) my ([\d])(nd|rd|st|th) aspect$/ do |word1, word2, aspect_number, nd|
  steps %Q{
    And I press the first ".toggle.button"
    And I press the #{aspect_number}#{nd} "li" within ".dropdown.active .dropdown_list"
    And I press the first ".toggle.button"
  }
end

When /^I add the person to a new aspect called "([^\"]*)"$/ do |aspect_name|
  steps %Q{
    And I press the first ".toggle.button"

    And I press click ".new_aspect" within ".dropdown.active"
    And I fill in "#aspect_name" with "#{aspect_name}"
    And I submit the form

    And I wait for the ajax to finish
    And I press the first ".toggle.button"
  }
end

When /^I post a status with the text "([^\"]*)"$/ do |text|
  @me.post(:status_message, :text => text, :public => true, :to => 'all')
end


And /^I follow the "([^\"]*)" link from the last sent email$/ do |link_text|
  email_text = Devise.mailer.deliveries.first.body.to_s
  email_text = Devise.mailer.deliveries.first.html_part.body.raw_source if email_text.blank?
  doc = Nokogiri(email_text)
  links = doc.css('a')
  link = links.detect{ |link| link.text == link_text }
  link = links.detect{ |link| link.attributes["href"].value.include?(link_text)} unless link
  path = link.attributes["href"].value
  visit URI::parse(path).request_uri
end

When /^"([^\"]+)" has posted a status message with a photo$/ do |email|
  user = User.find_for_database_authentication(:username => email)
  post = Factory(:status_message_with_photo, :text => "Look at this dog", :author => user.person)
  [post, post.photos.first].each do |p|
    user.add_to_streams(p, user.aspects)
    user.dispatch_post(p)
  end
end

Then /^my "([^\"]*)" should be "([^\"]*)"$/ do |field, value|
  @me.reload.send(field).should == value
end

Given /^I have (\d+) contacts$/ do |n|
  count = n.to_i - @me.contacts.count

  people = []
  contacts = []
  aspect_memberships = []

  count.times do
    person = Factory.create(:person)
    people << person
  end

  people.each do |person|
    contacts << Contact.new(:person_id => person.id, :user_id => @me.id, :sharing => true, :receiving => true)
  end
  Contact.import(contacts)
  contacts = @me.contacts.limit(n.to_i)

  aspect_id = @me.aspects.first.id
  contacts.each do |contact|
    aspect_memberships << AspectMembership.new(:contact_id => contact.id, :aspect_id => @me.aspects.first.id)
  end
  AspectMembership.import(aspect_memberships)
end
