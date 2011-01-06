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
        aspect.name.should == "Family"
        aspect.mongo_id.should == "4d0916c2cc8cb40e93000004"
        aspect.user_mongo_id.should == "4d0916c1cc8cb40e93000002"
      end
    end

    describe "aspect_memberships" do
      before do
        copy_fixture_for("aspect_memberships")
      end

      it "imports data into the mongo_aspect_memberships table" do
        Mongo::AspectMembership.count.should == 0
        @migrator.import_raw_aspect_memberships
        Mongo::AspectMembership.count.should == 17
      end

      it "imports all the columns" do
        @migrator.import_raw_aspect_memberships
        aspectm = Mongo::AspectMembership.first
        aspectm.contact_mongo_id.should == "4d0916c4cc8cb40e9300000a"
        aspectm.aspect_mongo_id.should =="4d0916c2cc8cb40e93000004"
      end
    end

    describe "comments" do
      before do
        copy_fixture_for("comments")
      end

      it "imports data into the mongo_comments table" do
        Mongo::Comment.count.should == 0
        @migrator.import_raw_comments
        Mongo::Comment.count.should == 5
      end

      it "imports all the columns" do
        @migrator.import_raw_comments
        comment = Mongo::Comment.first
        comment.text.should_not be_nil
        comment.person_mongo_id.should_not be_nil
        comment.post_mongo_id.should_not be_nil
      end
    end
    describe "contacts" do
      before do
        copy_fixture_for("contacts")
      end

      it "imports data into the mongo_contacts table" do
        Mongo::Contact.count.should == 0
        @migrator.import_raw_contacts
        Mongo::Contact.count.should == 16
      end

      it "imports all the columns" do
        @migrator.import_raw_contacts
        contact = Mongo::Contact.first
        contact.mongo_id.should == "4d0916c4cc8cb40e9300000a"
        contact.user_mongo_id.should =="4d0916c1cc8cb40e93000002"
        contact.person_mongo_id.should == "4d0916c3cc8cb40e93000007"
        contact.pending.should be_false
        contact.created_at.should be_nil
      end
    end

    describe "post_visibilities" do
      before do
        copy_fixture_for("post_visibilities")
      end

      it "imports data into the mongo_post_visibilities table" do
        Mongo::PostVisibility.count.should == 0
        @migrator.import_raw_post_visibilities
        Mongo::PostVisibility.count.should == 44
      end

      it "imports all the columns" do
        @migrator.import_raw_post_visibilities
        pv = Mongo::PostVisibility.first
        pv.post_mongo_id.should == "4d0aa87acc8cb4144b000009"
        pv.aspect_mongo_id.should =="4d0916c2cc8cb40e93000004"
      end
    end

    describe "users" do
      before do
        copy_fixture_for("users")
      end
      it "imports data into the mongo_users table" do
        Mongo::User.count.should == 0
        @migrator.import_raw_users
        Mongo::User.count.should == 10
      end
      it "imports all the columns" do
        @migrator.import_raw_users
        bob = Mongo::User.first
        bob.mongo_id.should == "4d090bd1cc8cb4054e000295"
        bob.username.should == "bob16203059c"
        bob.serialized_private_key.should_not be_nil
        bob.encrypted_password.should_not be_nil
        bob.invites.should == 5
        bob.invitation_token.should == ""
        bob.invitation_sent_at.should be_nil
        bob.getting_started.should be_false
        bob.disable_mail.should be_false
        bob.language.should == 'en'
        bob.last_sign_in_ip.should == ''
        bob.last_sign_in_at.to_i.should == 1292546796
        bob.reset_password_token.should == ""
        bob.password_salt.should_not be_nil
      end
    end
  end
end
