# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'
Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

describe DataConversion::ImportToMysql do

  # load data infile messes with transactional rollback
  self.use_transactional_fixtures = false

  def copy_fixture_for(table_name)
    FileUtils.cp("#{Rails.root}/spec/fixtures/data_conversion/#{table_name}.csv",
                 "#{@migrator.full_path}/#{table_name}.csv")
  end

  def import_and_process(table_name)
    copy_fixture_for(table_name)
    @migrator.send("import_raw_#{table_name}".to_sym)
    @migrator.send("process_raw_#{table_name}".to_sym)
  end

  def delete_everything
    Mongo::User.delete_all
    Mongo::Aspect.delete_all
    Mongo::AspectMembership.delete_all
    Mongo::Comment.delete_all
    Mongo::Invitation.delete_all
    Mongo::Notification.delete_all
    Mongo::Person.delete_all
    Mongo::Profile.delete_all
    Mongo::Post.delete_all
    Mongo::Contact.delete_all
    Mongo::PostVisibility.delete_all
    Mongo::Request.delete_all
    Mongo::Service.delete_all

    User.delete_all
    AspectMembership.delete_all
    Aspect.delete_all
    Comment.delete_all
    Invitation.delete_all
    Notification.delete_all
    Person.delete_all
    Profile.delete_all
    Post.delete_all
    Contact.delete_all
    PostVisibility.delete_all
    Request.delete_all
    Service.delete_all
  end

  before do
    delete_everything
    @migrator = DataConversion::ImportToMysql.new
    @migrator.full_path = "/tmp/data_conversion"
    system("rm -rf #{@migrator.full_path}")
    FileUtils.mkdir_p(@migrator.full_path)
  end

  describe "#process_raw" do
    describe "users" do
      before do
        copy_fixture_for("users")
        @migrator.import_raw_users
      end
      it "imports data into the users table" do
        lambda {
          @migrator.process_raw_users
        }.should change(User, :count).by(Mongo::User.count)
      end
      it "imports all the columns" do
        @migrator.process_raw_users
        bob = User.where(:mongo_id => "4d2b6eb6cc8cb43cc2000007").first
        bob.username.should == "bob1d2f837"
        bob.email.should == "bob1a25dee@pivotallabs.com"
        bob.serialized_private_key.should_not be_nil
        bob.encrypted_password.should_not be_nil
        bob.invites.should == 4
        bob.invitation_token.should be_nil
        bob.invitation_sent_at.should be_nil
        bob.getting_started.should be_true
        bob.disable_mail.should be_false
        bob.language.should == 'en'
        bob.last_sign_in_ip.should be_nil
        bob.last_sign_in_at.to_i.should_not be_nil
        bob.reset_password_token.should be_nil
        bob.password_salt.should_not be_nil
      end
    end
    describe "aspects" do
      before do
        import_and_process("users")
        copy_fixture_for("aspects")
        @migrator.import_raw_aspects
      end
      it "imports data into the aspects table" do
        lambda {
          @migrator.process_raw_aspects
        }.should change(Aspect, :count).by(Mongo::Aspect.count)
      end
      it "imports all the columns" do
        @migrator.process_raw_aspects
        aspect = Aspect.where(:mongo_id => "4d2b6eb6cc8cb43cc2000008").first
        aspect.name.should == "generic"
        aspect.contacts_visible.should == false
        aspect.user_mongo_id.should == "4d2b6eb6cc8cb43cc2000007"
      end
      it "sets the relation column" do
        @migrator.process_raw_aspects
        aspect = Aspect.where(:mongo_id => "4d2b6eb6cc8cb43cc2000008").first
        aspect.user.should == User.where(:mongo_id => aspect.user_mongo_id).first
      end
    end

    describe "services" do
      before do
        import_and_process("users")
        copy_fixture_for("services")
        @migrator.import_raw_services
      end

      it "imports data into the services table" do
        lambda {
          @migrator.process_raw_services
        }.should change(Service, :count).by(Mongo::Service.count)
      end

      it "imports all the columns" do
        @migrator.process_raw_services
        service = Service.where(:mongo_id => "4d2b6ec4cc8cb43cc200003e").first
        service.type_before_type_cast.should == "Services::Facebook"
        service.user_mongo_id.should == "4d2b6eb7cc8cb43cc2000014"
        service.uid.should be_nil
        service.access_token.should == "yeah"
        service.access_secret.should be_nil
        service.nickname.should be_nil
      end
      it 'sets the relation column' do
        @migrator.process_raw_services
        service = Service.where(:mongo_id => "4d2b6ec4cc8cb43cc200003e").first
        service.user_id.should == User.where(:mongo_id => service.user_mongo_id).first.id
      end
    end

    describe "invitations" do
      before do
        import_and_process("users")
        import_and_process("aspects")
        copy_fixture_for("invitations")
        @migrator.import_raw_invitations
      end

      it "imports data into the mongo_invitations table" do
        Mongo::Invitation.count.should == 1
        Invitation.count.should == 0
        @migrator.process_raw_invitations
        Invitation.count.should == 1
      end

      it "imports all the columns" do
        @migrator.process_raw_invitations
        invitation = Invitation.first
        invitation.mongo_id.should == "4d2b6ebecc8cb43cc2000026"
        invitation.message.should == "Hello!"
      end
      it 'sets the relation columns' do
        @migrator.process_raw_invitations
        invitation = Invitation.first
        mongo_invitation = Mongo::Invitation.where(:mongo_id => invitation.mongo_id).first
        invitation.sender_id.should == User.where(:mongo_id => mongo_invitation.sender_mongo_id).first.id
        invitation.recipient_id.should == User.where(:mongo_id => mongo_invitation.recipient_mongo_id).first.id
      end
    end
    describe "requests" do
      before do
        import_and_process("users")
        import_and_process("people")
        import_and_process("aspects")
        copy_fixture_for("requests")
        @migrator.import_raw_requests
      end

      it "imports data into the mongo_requests table" do
        Mongo::Request.count.should == 2
        Request.count.should == 0
        @migrator.process_raw_requests
        Request.count.should == 2
      end

      it "imports all the columns" do
        @migrator.process_raw_requests
        request = Request.first
        request.mongo_id.should == "4d2b6eb8cc8cb43cc200001e"
      end
      it 'sets the relation columns' do
        @migrator.process_raw_requests
        request = Request.first
        mongo_request = Mongo::Request.where(:mongo_id => request.mongo_id).first
        request.sender_id.should == Person.where(:mongo_id => mongo_request.sender_mongo_id).first.id
        request.recipient_id.should == Person.where(:mongo_id => mongo_request.recipient_mongo_id).first.id
      end
    end
    describe "people" do
      before do
        import_and_process("users")
        copy_fixture_for("people")
        @migrator.import_raw_people
      end

      it "imports data into the people table" do
        lambda {
          @migrator.process_raw_people
        }.should change(Person, :count).by(Mongo::Person.count)
      end

      it "imports all the columns of a non-owned person" do
        @migrator.process_raw_people
        mongo_person = Mongo::Person.where(:mongo_id => "4d2b6eb6cc8cb43cc2000001").first
        person = Person.where(:mongo_id => "4d2b6eb6cc8cb43cc2000001").first
        person.owner_id.should be_nil
        person.guid.should == person.mongo_id
        person.url.should == "http://google-1b05052.com/"
        person.diaspora_handle.should == "bob-person-1fe12fb@aol.com"
        person.serialized_public_key.should_not be_nil
        person.created_at.should == mongo_person.created_at
      end

      it "imports all the columns of an owned person" do
        @migrator.process_raw_people
        mongo_person = Mongo::Person.first
        person = Person.where(:mongo_id => mongo_person.mongo_id).first
        person.guid.should == mongo_person.mongo_id
        person.url.should == mongo_person.url
        person.diaspora_handle.should == mongo_person.diaspora_handle
        person.serialized_public_key.should == mongo_person.serialized_public_key
        person.created_at.should == mongo_person.created_at
      end
      it 'sets the relational column of an owned person' do
        @migrator.process_raw_people
        mongo_person = Mongo::Person.where("mongo_people.owner_mongo_id IS NOT NULL").first
        person = Person.where(:mongo_id => mongo_person.mongo_id).first
        person.owner.should_not be_nil
        person.diaspora_handle.should include(person.owner.username)
      end
    end

    describe "contacts" do
      before do
        import_and_process("users")
        import_and_process("people")
        copy_fixture_for("contacts")
        @migrator.import_raw_contacts
      end

      it "imports data into the mongo_contacts table" do
        original_contact_count = Contact.unscoped.count
        @migrator.process_raw_contacts
        Contact.unscoped.count.should == original_contact_count + Mongo::Contact.count
      end

      it "imports all the columns" do
        @migrator.process_raw_contacts
        mongo_contact = Mongo::Contact.first
        contact = Contact.where(:mongo_id => mongo_contact.mongo_id).first
        contact.user_id.should == User.where(:mongo_id => mongo_contact.user_mongo_id).first.id
        contact.person_id.should == Person.where(:mongo_id => mongo_contact.person_mongo_id).first.id
        contact.pending.should be_false
      end
    end

    describe "aspect_memberships" do
      before do
        import_and_process("users")
        import_and_process("people")
        import_and_process("contacts")
        import_and_process("aspects")
        copy_fixture_for("aspect_memberships")
        @migrator.import_raw_aspect_memberships
      end

      it "imports data into the mongo_aspect_memberships table" do
        lambda {
          @migrator.process_raw_aspect_memberships
        }.should change(AspectMembership, :count).by(Mongo::AspectMembership.count)
      end

      it "imports all the columns" do
        @migrator.process_raw_aspect_memberships
        mongo_aspectm = Mongo::AspectMembership.first
        aspectm = AspectMembership.where(
          :contact_id => Contact.where(:mongo_id => mongo_aspectm.contact_mongo_id).first.id,
          :aspect_id => Aspect.where(:mongo_id => mongo_aspectm.aspect_mongo_id).first.id).first
        aspectm.should_not be_nil
      end
    end
    describe "profiles" do
      before do
        import_and_process("users")
        import_and_process("people")
        copy_fixture_for("profiles")
        @migrator.import_raw_profiles
      end

      it "processs data into the mongo_profiles table" do
        lambda {
          @migrator.process_raw_profiles
        }.should change(Profile, :count).by(Mongo::Profile.count)
      end

      it "processs all the columns" do
        @migrator.process_raw_profiles
        profile = Profile.where(:mongo_id => "4d2b6eb6cc8cb43cc2000001").first
        profile.image_url_medium.should be_nil
        profile.searchable.should == true
        profile[:image_url].should be_nil
        profile.gender.should be_nil
        profile.diaspora_handle.should == profile.person.diaspora_handle
        profile.last_name.should == 'weinstien'
        profile.bio.should be_nil
        profile.image_url_small.should be_nil
        profile.first_name.should == 'eugene'
      end
      it "sets the relation to person" do
        @migrator.process_raw_profiles
        profile = Profile.first
        profile.person_id.should == Person.where(:mongo_id => profile.mongo_id).first.id
      end
    end
    describe "posts" do
      before do
        import_and_process("users")
        import_and_process("people")
        copy_fixture_for("posts")
        @migrator.import_raw_posts
      end

      it "imports data into the posts table" do
        lambda {
          @migrator.process_raw_posts
        }.should change(Post, :count).by(Mongo::Post.count)
      end

      it "imports all the columns" do
        @migrator.process_raw_posts
        post = StatusMessage.first
        mongo_post = Mongo::Post.where(:mongo_id => post.mongo_id).first
        post.youtube_titles.should be_nil
        post.pending.should == false
        post.public.should == false
        post.status_message_id.should be_nil
        post.caption.should be_nil
        post.remote_photo_path.should be_nil
        post.remote_photo_name.should be_nil
        post.random_string.should be_nil
        post.image.should be_nil
        post.mongo_id.should == "4d2b6ebecc8cb43cc2000027"
        post.guid.should == post.mongo_id
        post.author_id.should == Person.where(:mongo_id => mongo_post.person_mongo_id).first.id
        post.diaspora_handle.should == post.author.diaspora_handle
        post.message.should == "User2 can see this"
        post.created_at.should == mongo_post.created_at
        post.updated_at.should == mongo_post.updated_at
      end

      it "imports the columns of a photo" do
        @migrator.process_raw_posts
        post = Photo.where(:mongo_id => "4d2b6ebfcc8cb43cc200002d").first
        mongo_post = Mongo::Post.where(:mongo_id => post.mongo_id).first
        post.youtube_titles.should be_nil
        post.pending.should == false
        post.public.should == false
        post.status_message_id.should == StatusMessage.where(:mongo_id => mongo_post.status_message_mongo_id).first.id
        post.caption.should be_nil
        post.remote_photo_path.should be_nil
        post.remote_photo_name.should be_nil
        post.random_string.should == "mUKUIxkYlV"
        post.image.file.file.should =~ /mUKUIxkYlV4d2b6ebfcc8cb43cc200002d\.png/
        post.mongo_id.should == "4d2b6ebfcc8cb43cc200002d"
        post.guid.should == post.mongo_id
        post.author_id.should == Person.where(:mongo_id => mongo_post.person_mongo_id).first.id
        post.diaspora_handle.should == post.author.diaspora_handle
        post.message.should be_nil
        post.created_at.should == mongo_post.created_at
        post.updated_at.should == mongo_post.updated_at
      end
    end
    describe "comments" do
      before do
        import_and_process("users")
        import_and_process("people")
        import_and_process("posts")
        copy_fixture_for("comments")
        @migrator.import_raw_comments
      end

      it "imports data into the comments table" do
        lambda {
          @migrator.process_raw_comments
        }.should change(Comment, :count).by(Mongo::Comment.count)
      end

      it "processes all the columns" do
        @migrator.process_raw_comments
        comment = Comment.first
        comment.mongo_id.should == "4d2b6ebfcc8cb43cc200002b"
        comment.text.should == "Hey me!"
        comment.youtube_titles.should be_nil
      end
      it 'sets the relations' do
        @migrator.process_raw_comments
        comment = Comment.first
        comment.post_id.should == Post.where(:mongo_id => "4d2b6ebecc8cb43cc2000029").first.id
        comment.author_id.should == Person.where(:mongo_id => "4d2b6eb7cc8cb43cc2000017").first.id
      end
    end
    describe "notifications" do
      before do
        import_and_process("users")
        import_and_process("people")
        import_and_process("posts")
        import_and_process("aspects")
        import_and_process("requests")
        copy_fixture_for("notifications")
        @migrator.import_raw_notifications
      end

      it "does not import notifications" do
        Mongo::Notification.count.should == 2
        Notification.count.should == 0
        @migrator.process_raw_notifications
        Notification.count.should == 0
      end
    end
    describe "post_visibilities" do
      before do
        import_and_process("users")
        import_and_process("people")
        import_and_process("aspects")
        import_and_process("posts")
        copy_fixture_for("post_visibilities")
        @migrator.import_raw_post_visibilities
      end

      it "imports data into the post_visibilities table" do
        Mongo::PostVisibility.count.should == 8
        PostVisibility.count.should == 0
        @migrator.process_raw_post_visibilities
        PostVisibility.count.should == 8
      end

      it "processes all the columns" do
        @migrator.process_raw_post_visibilities
        pv = PostVisibility.first
        mongo_pv = Mongo::PostVisibility.first
        pv.aspect.mongo_id.should == mongo_pv.aspect_mongo_id
        pv.post.mongo_id.should == mongo_pv.post_mongo_id
      end
    end
  end
  describe "#import_raw" do
    describe "aspects" do
      before do
        copy_fixture_for("aspects")
      end

      it "imports data into the mongo_aspects table" do
        Mongo::Aspect.count.should == 0
        @migrator.import_raw_aspects
        Mongo::Aspect.count.should == 4
      end

      it "imports all the columns" do
        @migrator.import_raw_aspects
        aspect = Mongo::Aspect.first
        aspect.name.should == "generic"
        aspect.mongo_id.should == "4d2b6eb6cc8cb43cc2000008"
        aspect.user_mongo_id.should == "4d2b6eb6cc8cb43cc2000007"
      end
    end

    describe "aspect_memberships" do
      before do
        copy_fixture_for("aspect_memberships")
      end

      it "imports data into the mongo_aspect_memberships table" do
        Mongo::AspectMembership.count.should == 0
        @migrator.import_raw_aspect_memberships
        Mongo::AspectMembership.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_aspect_memberships
        aspectm = Mongo::AspectMembership.first
        aspectm.contact_mongo_id.should == "4d2b6eb7cc8cb43cc200000f"
        aspectm.aspect_mongo_id.should == "4d2b6eb6cc8cb43cc2000008"
      end
    end

    describe "comments" do
      before do
        copy_fixture_for("comments")
      end

      it "imports data into the mongo_comments table" do
        Mongo::Comment.count.should == 0
        @migrator.import_raw_comments
        Mongo::Comment.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_comments
        comment = Mongo::Comment.first
        comment.mongo_id.should == "4d2b6ebfcc8cb43cc200002b"
        comment.text.should == "Hey me!"
        comment.post_mongo_id.should == "4d2b6ebecc8cb43cc2000029"
        comment.person_mongo_id.should == "4d2b6eb7cc8cb43cc2000017"
        comment.youtube_titles.should be_nil
      end
    end
    describe "contacts" do
      before do
        copy_fixture_for("contacts")
      end

      it "imports data into the mongo_contacts table" do
        Mongo::Contact.count.should == 0
        @migrator.import_raw_contacts
        Mongo::Contact.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_contacts
        contact = Mongo::Contact.first
        contact.mongo_id.should == "4d2b6eb7cc8cb43cc200000f"
        contact.user_mongo_id.should =="4d2b6eb6cc8cb43cc2000007"
        contact.person_mongo_id.should == "4d2b6eb7cc8cb43cc200000e"
        contact.pending.should be_false
      end
    end
    describe "invitations" do
      before do
        copy_fixture_for("invitations")
      end

      it "imports data into the mongo_invitations table" do
        Mongo::Invitation.count.should == 0
        @migrator.import_raw_invitations
        Mongo::Invitation.count.should == 1
      end

      it "imports all the columns" do
        @migrator.import_raw_invitations
        invitation = Mongo::Invitation.first
        invitation.mongo_id.should == "4d2b6ebecc8cb43cc2000026"
        invitation.recipient_mongo_id.should =="4d2b6ebccc8cb43cc2000025"
        invitation.sender_mongo_id.should == "4d2b6eb6cc8cb43cc2000007"
        invitation.aspect_mongo_id.should == '4d2b6eb6cc8cb43cc2000008'
        invitation.message.should == "Hello!"
      end
    end

    describe "posts" do
      before do
        copy_fixture_for("posts")
      end

      it "imports data into the mongo_posts table" do
        Mongo::Post.count.should == 0
        @migrator.import_raw_posts
        Mongo::Post.count.should == 6
      end

      it "imports all the columns" do
        @migrator.import_raw_posts
        post = Mongo::Post.first
        post.youtube_titles.should be_nil
        post.pending.should == false
        post.public.should == false
        post.status_message_mongo_id.should be_nil
        post.caption.should be_nil
        post.remote_photo_path.should be_nil
        post.remote_photo_name.should be_nil
        post.random_string.should be_nil
        post.image.should be_nil
        post.mongo_id.should == "4d2b6ebecc8cb43cc2000027"
        post.guid.should == post.mongo_id
        post.type.should == "StatusMessage"
        post.diaspora_handle.should == "bob1d2f837@localhost"
        post.person_mongo_id.should == "4d2b6eb6cc8cb43cc200000a"
        post.message.should == "User2 can see this"
        Mongo::Post.where(:mongo_id => "4d2b6ebfcc8cb43cc200002d").first.status_message_mongo_id.should == post.mongo_id
        # puts post.created_at.utc? # == true
        post.created_at.utc.to_i.should == 1294692030 # got 1294663230- minus 8 hours
        post.updated_at.to_i.should == 1294692030
      end

    end
    describe "notifications" do
      before do
        copy_fixture_for("notifications")
      end

      it "imports data into the mongo_notifications table" do
        Mongo::Notification.count.should == 0
        @migrator.import_raw_notifications
        Mongo::Notification.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_notifications
        notification = Mongo::Notification.first
        notification.mongo_id.should == "4d2b6eb8cc8cb43cc200001f"
        notification.target_mongo_id.should == '4d2b6eb8cc8cb43cc200001e'
        notification.recipient_mongo_id.should == "4d2b6eb7cc8cb43cc2000018"
        notification.actor_mongo_id.should == "4d2b6eb7cc8cb43cc2000017"
        notification.action.should == "new_request"
        notification.unread.should be_true
        notification.target_type.should == "Request"
      end
    end


    describe "people" do
      before do
        copy_fixture_for("people")
      end

      it "imports data into the mongo_people table" do
        Mongo::Person.count.should == 0
        @migrator.import_raw_people
        Mongo::Person.count.should == 10
      end

      it "imports all the columns" do
        @migrator.import_raw_people
        person = Mongo::Person.first
        person.owner_mongo_id.should be_nil
        person.mongo_id.should == "4d2b6eb6cc8cb43cc2000001"
        person.guid.should == person.mongo_id
        person.url.should == "http://google-1b05052.com/"
        person.diaspora_handle.should == "bob-person-1fe12fb@aol.com"
        person.serialized_public_key.should_not be_nil
        person.created_at.to_i.should == 1294692022
      end
    end
    describe "post_visibilities" do
      before do
        copy_fixture_for("post_visibilities")
      end

      it "imports data into the mongo_post_visibilities table" do
        Mongo::PostVisibility.count.should == 0
        @migrator.import_raw_post_visibilities
        Mongo::PostVisibility.count.should == 8
      end

      it "imports all the columns" do
        @migrator.import_raw_post_visibilities
        pv = Mongo::PostVisibility.first
        pv.aspect_mongo_id.should == "4d2b6eb6cc8cb43cc2000008"
        pv.post_mongo_id.should == "4d2b6ebecc8cb43cc2000027"
      end
    end
    describe "profiles" do
      before do
        copy_fixture_for("profiles")
      end

      it "imports data into the mongo_profiles table" do
        Mongo::Profile.count.should == 0
        @migrator.import_raw_profiles
        Mongo::Profile.count.should == 10
      end

      it "imports all the columns" do
        @migrator.import_raw_profiles
        profile = Mongo::Profile.first
        profile.image_url_medium.should be_nil
        profile.searchable.should == true
        profile.image_url.should be_nil
        profile.person_mongo_id.should == "4d2b6eb6cc8cb43cc2000001"
        profile.gender.should be_nil
        profile.diaspora_handle.should be_nil
        profile.last_name.should == 'weinstien'
        profile.bio.should be_nil
        profile.image_url_small.should be_nil
        profile.first_name.should == 'eugene'
      end
    end

    describe "requests" do
      before do
        copy_fixture_for("requests")
      end

      it "imports data into the mongo_requests table" do
        Mongo::Request.count.should == 0
        @migrator.import_raw_requests
        Mongo::Request.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_requests
        request = Mongo::Request.first
        request.mongo_id.should == "4d2b6eb8cc8cb43cc200001e"
        request.recipient_mongo_id.should == "4d2b6eb7cc8cb43cc200001b"
        request.sender_mongo_id.should == "4d2b6eb7cc8cb43cc2000017"
        request.aspect_mongo_id.should be_nil
      end
    end
    describe "services" do
      before do
        copy_fixture_for("services")
      end

      it "imports data into the mongo_services table" do
        Mongo::Service.count.should == 0
        @migrator.import_raw_services
        Mongo::Service.count.should == 2
      end

      it "imports all the columns" do
        @migrator.import_raw_services
        service = Mongo::Service.first
        service.mongo_id.should == "4d2b6ec4cc8cb43cc200003e"
        service.type_before_type_cast.should == "Services::Facebook"
        service.user_mongo_id.should == "4d2b6eb7cc8cb43cc2000014"
        service.uid.should be_nil
        service.access_token.should == "yeah"
        service.access_secret.should be_nil
        service.nickname.should be_nil
      end
    end
    describe "users" do
      before do
        copy_fixture_for("users")
      end
      it "imports data into the mongo_users table" do
        Mongo::User.count.should == 0
        @migrator.import_raw_users
        Mongo::User.count.should == 6
      end
      it "imports all the columns" do
        @migrator.import_raw_users
        bob = Mongo::User.first
        bob.mongo_id.should == "4d2b6eb6cc8cb43cc2000007"
        bob.username.should == "bob1d2f837"
        bob.email.should == "bob1a25dee@pivotallabs.com"
        bob.serialized_private_key.should_not be_nil
        bob.encrypted_password.should_not be_nil
        bob.invites.should == 4
        bob.invitation_token.should be_nil
        bob.invitation_sent_at.should be_nil
        bob.getting_started.should be_true
        bob.disable_mail.should be_false
        bob.language.should == 'en'
        bob.last_sign_in_ip.should be_nil
        bob.last_sign_in_at.to_i.should_not be_nil
        bob.reset_password_token.should be_nil
        bob.password_salt.should_not be_nil
      end
    end
  end

  # Otherwise, subsequent tests can't load the fixtures
  self.use_transactional_fixtures = true
end
