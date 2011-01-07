# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'
Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

describe DataConversion::ImportToMysql do
  def copy_fixture_for(table_name)
    FileUtils.cp("#{Rails.root}/spec/fixtures/data_conversion/#{table_name}.csv",
                 "#{@migrator.full_path}/#{table_name}.csv")
  end

  before do
    @migrator = DataConversion::ImportToMysql.new
    @migrator.full_path = "/tmp/data_conversion"
    system("rm -rf #{@migrator.full_path}")
    FileUtils.mkdir_p(@migrator.full_path)
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
        aspect.mongo_id.should == "4d26212bcc8cb44df2000006"
        aspect.user_mongo_id.should == "4d26212acc8cb44df2000005"
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
        aspectm.contact_mongo_id.should == "4d26212bcc8cb44df200000d"
        aspectm.aspect_mongo_id.should == "4d26212bcc8cb44df2000006"
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
        comment.mongo_id.should == "4d262132cc8cb44df2000027"
        comment.text.should == "Hey me!"
        comment.person_mongo_id.should == "4d26212bcc8cb44df2000014"
        comment.post_mongo_id.should == "4d262132cc8cb44df2000025"
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
        contact.mongo_id.should == "4d26212bcc8cb44df200000d"
        contact.user_mongo_id.should =="4d26212acc8cb44df2000005"
        contact.person_mongo_id.should == "4d26212bcc8cb44df200000c"
        contact.pending.should be_false
        contact.created_at.should be_nil
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
        invitation.mongo_id.should == "4d262131cc8cb44df2000022"
        invitation.recipient_mongo_id.should =="4d26212fcc8cb44df2000021"
        invitation.sender_mongo_id.should == "4d26212acc8cb44df2000005"
        invitation.aspect_mongo_id.should == '4d26212bcc8cb44df2000006'
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
        post.created_at.to_i.should == 1294358525000
        post.public.should == false
        post.updated_at.to_i.should == 1294358525000
        post.status_message_mongo_id.should be_nil
        post.caption.should be_nil
        post.remote_photo_path.should be_nil
        post.remote_photo_name.should be_nil
        post.random_string.should be_nil
        post.image.should be_nil
        post.mongo_id.should == "4d2657fdcc8cb46033000023"
        post.guid.should == post.mongo_id
        post.type.should == "StatusMessage"
        post.diaspora_handle.should == "bob14cbf20@localhost"
        post.person_mongo_id.should == "4d2657e9cc8cb46033000008"
        post.message.should == "User2 can see this"
      end
    end
    describe "notifications" do
      before do
        copy_fixture_for("notifications")
      end

      it "imports data into the mongo_notifications table" do
        Mongo::Notification.count.should == 0
        @migrator.import_raw_notifications
        Mongo::Notification.count.should == 3
      end

      it "imports all the columns" do
        @migrator.import_raw_notifications
        notification = Mongo::Notification.first
        notification.mongo_id.should == "4d26212ccc8cb44df200001c"
        notification.target_mongo_id.should == '4d26212ccc8cb44df200001b'
        notification.target_type.should == "new_request"
        notification.unread.should be_true
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
        person.mongo_id.should == "4d26212acc8cb44df2000002"
        person.guid.should == person.mongo_id
        person.url.should == "http://google-1b5b16a.com/"
        person.diaspora_handle.should == "bob-person-1a8bc18@aol.com"
        person.serialized_public_key.should_not be_nil
        person.created_at.should be_nil
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
        pv.post_mongo_id.should == "4d262132cc8cb44df2000023"
        pv.aspect_mongo_id.should =="4d26212bcc8cb44df2000006"
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
        profile.person_mongo_id.should == "4d262129cc8cb44df2000001"
        profile.gender.should be_nil
        profile.diaspora_handle.should be_nil
        profile.birthday.should be_nil
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
        request.mongo_id.should == "4d26212ccc8cb44df200001b"
        request.recipient_mongo_id.should =="4d26212bcc8cb44df2000018"
        request.sender_mongo_id.should == "4d26212bcc8cb44df2000014"
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
        service.type_before_type_cast.should == "Services::Facebook"
        service.user_mongo_id.should == "4d2657eacc8cb46033000011"
        service.provider.should be_nil
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
        bob.mongo_id.should == "4d26212acc8cb44df2000005"
        bob.username.should == "bob178fa79"
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
end
