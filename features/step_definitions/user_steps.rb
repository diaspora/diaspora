# frozen_string_literal: true

Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  @me ||= FactoryGirl.create(:user, :username => username, :password => password,
                  :password_confirmation => password, :getting_started => false)
  @me.aspects.create(:name => "Besties")
  @me.aspects.create(:name => "Unicorns")
  @me.reload
end

Given /^a user with email "([^\"]*)"$/ do |email|
  create_user(:email => email)
end

Given /^a user with username "([^\"]*)"$/ do |username|
  create_user(:email => username + "@" + username + '.' + username, :username => username)
end

Given /^a user named "([^\"]*)" with email "([^\"]*)"$/ do |name, email|
  first, last = name.split
  user = create_user(:email => email, :username => "#{first}_#{last}")
  user.profile.update_attributes!(:first_name => first, :last_name => last) if first
end

Given /^a nsfw user with email "([^\"]*)"$/ do |email|
  user = create_user(:email => email)
  user.profile.update_attributes(:nsfw => true)
end

Given /^a moderator with email "([^\"]*)"$/ do |email|
  user = create_user(email: email)
  Role.add_moderator(user)
end

Given /^an admin with email "([^\"]*)"$/ do |email|
  user = create_user(email: email)
  Role.add_admin(user)
end

Given /^(?:|[tT]hat )?following user[s]?(?: exist[s]?)?:$/ do |table|
  table.hashes.each do |hash|
    if hash.has_key? "username" and hash.has_key? "email"
      step %{a user named "#{hash['username']}" with email "#{hash['email']}"}
    elsif hash.has_key? "username"
      step %{a user with username "#{hash['username']}"}
    elsif hash.has_key? "email"
      step %{a user with email "#{hash['email']}"}
    end
  end
end

Given /^I have been invited by an admin$/ do
  admin = FactoryGirl.create(:user)
  admin.invitation_code
  i = EmailInviter.new("new_invitee@example.com", admin)
  i.send!
end

Given /^I have been invited by "([^\"]+)"$/ do |email|
  AppConfig.settings.enable_registrations = false
  @inviter = User.find_by_email(email)
  @inviter_invite_count = @inviter.invitation_code.count
  i = EmailInviter.new("new_invitee@example.com", @inviter)
  i.send!
end

When /^I should see one less invite$/ do
  step "I should see \"#{@inviter_invite_count -1} invites left\""
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end

When /^I have user with username "([^"]*)" in an aspect called "([^"]*)"$/ do |username, aspect|
  user = User.find_by_username(username)
  contact = @me.reload.contact_for(user.person)
  contact.aspects << @me.aspects.find_by_name(aspect)
end

Given /^a user with email "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:email => arg1).first
  user2 = User.where(:email => arg2).first
  connect_users(user1, user1.aspects.where(:name => "Besties").first, user2, user2.aspects.where(:name => "Besties").first)
end

Given /^a user with username "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:username => arg1).first
  user2 = User.where(:username => arg2).first
  connect_users(user1, user1.aspects.where(:name => "Besties").first, user2, user2.aspects.where(:name => "Besties").first)
end

Given /^there is a user "([^\"]*)" who's tagged "([^\"]*)"$/ do |full_name, tag|
  username = full_name.gsub(/\W/, "").underscore
  step "a user named \"#{full_name}\" with email \"#{username}@example.com\""
  user = User.find_by_username(username)
  user.profile.tag_string = tag
  user.profile.build_tags
  user.profile.save!
end

Given /^a user with email "([^\"]*)" is tagged "([^\"]*)"$/ do |email, tags|
  user = User.find_by_email(email)
  user.profile.tag_string = tags
  user.profile.build_tags
  user.profile.save!
end

Given /^many posts from alice for bob$/ do
  alice = FactoryGirl.create(:user_with_aspect, :username => 'alice', :email => 'alice@alice.alice', :password => 'password', :getting_started => false)
  bob = FactoryGirl.create(:user_with_aspect, :username => 'bob', :email => 'bob@bob.bob', :password => 'password', :getting_started => false)
  connect_users_with_aspects(alice, bob)
  time_fulcrum = Time.now - 40000
  time_interval = 1000
  (1..30).each do |n|
    post = alice.post :status_message, :text => "#{alice.username} - #{n} - #seeded", :to => alice.aspects.where(:name => "generic").first.id
    post.created_at = time_fulcrum - time_interval
    post.updated_at = time_fulcrum + time_interval
    post.save
    time_interval += 1000
  end
end

Then /^I should have (\d) contacts? in "([^"]*)"$/ do |n_contacts, aspect_name|
  @me.aspects.where(:name => aspect_name).first.contacts.count.should == n_contacts.to_i
end

When /^I (?:add|remove) the person (?:to|from) my "([^\"]*)" aspect(?: within "([^"]*)")?$/ do |aspect_name, within_selector| # rubocop:disable Metrics/LineLength
  with_scope(within_selector) do
    toggle_aspect_via_ui(aspect_name)
  end
end

When /^I post a status with the text "([^\"]*)"$/ do |text|
  @me.post(:status_message, :text => text, :public => true, :to => 'all')
end

When /^I post a limited status with the text "([^\"]*)"$/ do |text|
  @me.post(:status_message, :text => text, :public => false, :to => @me.aspect_ids)
end

And /^I follow the "([^\"]*)" link from the last sent email$/ do |link_text|
  email_text = Devise.mailer.deliveries.first.body.to_s
  email_text = Devise.mailer.deliveries.first.html_part.body.raw_source if email_text.blank?
  doc = Nokogiri("<div>" + email_text + "</div>")

  links = doc.css('a')
  link = links.detect{ |link| link.text == link_text }
  link = links.detect{ |link| link.attributes["href"].value.include?(link_text)} unless link
  path = link.attributes["href"].value
  visit URI::parse(path).request_uri
end

Then /^I should have (\d+) Devise email delivery$/ do |n|
  Devise.mailer.deliveries.length.should == n.to_i
end

Then /^I should have (\d+) email delivery$/ do |n|
  ActionMailer::Base.deliveries.length.should == n.to_i
end

Then /^I should( not)? see "([^\"]*)" in the last sent email$/ do |negate, text|
  email_text = Devise.mailer.deliveries.first.body.to_s
  email_text = Devise.mailer.deliveries.first.html_part.body.raw_source if email_text.blank?
  if negate
    expect(email_text).to_not have_content(text)
  else
    expect(email_text).to have_content(text)
  end
end

When /^"([^\"]+)" has posted a (public )?status message with a photo$/ do |email, public_status|
  user = User.find_for_database_authentication(:username => email)
  post = FactoryGirl.create(
    :status_message_with_photo,
    text:   "Look at this dog",
    author: user.person,
    public: public_status.present?
  )
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
    person = FactoryGirl.create(:person)
    people << person
  end

  people.each do |person|
    contacts << Contact.new(:person_id => person.id, :user_id => @me.id, :sharing => true, :receiving => true)
  end
  Contact.import(contacts)
  contacts = @me.contacts.limit(n.to_i)

  aspect_id = @me.aspects.length == 1 ? @me.aspects.first.id : @me.aspects.where(:name => "Besties").first.id
  contacts.each do |contact|
    aspect_memberships << AspectMembership.new(:contact_id => contact.id, :aspect_id => aspect_id)
  end
  AspectMembership.import(aspect_memberships)
end

When /^I view "([^\"]*)"'s first post$/ do |email|
  user = User.find_by_email(email)
  post = user.posts.first
  visit post_path(post)
end

And /^I should be able to friend "([^\"]*)"$/ do |email|
  user = User.find_by_email(email)
  step 'I should see a ".aspect-dropdown"'
  step "I should see \"#{user.name}\""
end

Given /^I did request my photos$/ do
  @me.perform_export_photos!
end

Then /^I should get a zipped file$/ do
  expect(page.response_headers["Content-Type"]).to eq("application/zip")
end

And /^a person with ID "([^\"]*)" has been discovered$/ do |diaspora_id|
  FactoryGirl.create(:person, diaspora_handle: diaspora_id)
end
