namespace :fixtures do
  desc 'Regenerates user fixtures'
  task :users do
    puts "Regenerating fixtures for users."
    require File.join(Rails.root,"config/environment")
    require File.join(Rails.root,"spec/helper_methods")
    require File.join(Rails.root,"spec/factories")
    include HelperMethods
    UserFixer.regenerate_user_fixtures
    puts "Fixture regeneration complete."
  end
  task :for_mysql_export do
    puts "Populating DB for export."
    require File.join(Rails.root,"config/environment")
    require File.join(Rails.root,"spec/helper_methods")
    require File.join(Rails.root,"spec/factories")
    require File.join(Rails.root,"spec/support/user_methods")
    require File.join(Rails.root,"spec/support/fake_resque")

    include HelperMethods

    Jobs::HttpPost.class_eval do
      def self.perform(*args)
      end
    end
    fantasy_resque do
      models = []
      Factory(:person)
      Factory(:person)
      Factory(:person)
      user1 = Factory(:user_with_aspect)
      user2 = Factory(:user_with_aspect)
      connect_users(user1, user1.aspects.first, user2, user2.aspects.first)
      user2.activate_contact(Factory(:person), user2.aspects.first)
      user2.reload

      user3 = Factory(:user_with_aspect)
      user4 = Factory(:user_with_aspect)
      user3.send_contact_request_to(user4.person, user3.aspects.first)
      user3.reload; user4.reload
      user3.send_contact_request_to(Factory(:person), user3.aspects.first)

      batch_invitee = Invitation.create_invitee(:email => "random@example.com", :name => "Curious George", :invites => 3)
      invitee = user1.invite_user("random2@example.net", user1.aspects.first.id, "Hello!")
      user1.reload

      u1post = user1.post(:status_message, :message => "User2 can see this", :to => [user1.aspects.first.id])
      user1.reload
      u3post = user3.post(:status_message, :message => "User3 can see this", :to => [user3.aspects.first.id])
      user3.reload
      user3.comment("Hey me!", :on => u3post)
      user3.reload
      user2.comment("Hey you!", :on => u1post)
      user2.reload

      user2.post(:photo, :user_file => uploaded_photo, :to => [user2.aspects.first.id])
      user2.reload
      user3.post(:photo, :user_file => uploaded_photo, :to => [user3.aspects.first.id])
      user3.reload

      remote_user = Factory(:user_with_aspect)
      user4.activate_contact(remote_user.person, user4.aspects.first)
      user4.reload
      remote_message = remote_user.build_post(:photo, :user_file => uploaded_photo, :to => remote_user.aspects.first.id)
      remote_photo = remote_user.build_post(:status_message, :message => "from another server!", :to => remote_user.aspects.first.id)
      request = remote_user.send_contact_request_to(user2.person, remote_user.aspects.first)
      remote_user.reload
      remote_user.delete
      Contact.where(:user_id => remote_user.id).each{|c| c.delete}
      Aspect.where(:user_id => remote_user.id).each{|c| c.delete}
      remote_person = remote_user.person
      remote_person.owner_id = nil
      remote_person.save

      user4.receive(remote_message.to_diaspora_xml, remote_person)
      user3.reload
      user4.receive(remote_photo.to_diaspora_xml, remote_person)
      user3.reload


      facebook = Services::Facebook.new(:access_token => "yeah")
      user3.services << facebook
      facebook.save!

      twitter = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
      user2.services << twitter
      twitter.save!
    end
    puts "Done generating fixtures, you can now export"

  end
end
