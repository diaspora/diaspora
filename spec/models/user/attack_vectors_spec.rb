#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe "attack vectors" do

  let(:user) { Factory.create(:user_with_aspect) }
  let(:aspect) { user.aspects.first }

  let(:bad_user) { Factory.create(:user)}

  let(:user2) { eve }
  let(:aspect2) { user2.aspects.first }

  let(:user3) { Factory.create(:user) }
  let(:aspect3) { user3.aspects.create(:name => 'heroes') }

  context 'non-contact valid user' do

    it 'does not save a post from a non-contact' do
      post_from_non_contact = bad_user.build_post( :status_message, :text => 'hi')
      salmon_xml = bad_user.salmon(post_from_non_contact).xml_for(user.person)

      post_from_non_contact.delete
      bad_user.delete
      post_count = Post.count

      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      user.raw_visible_posts.include?(post_from_non_contact).should be_false
      Post.count.should == post_count
    end

  end

  it 'does not let a user attach to posts previously in the db unless its received from the author' do
    connect_users(user, aspect, user3, aspect3)

    original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id

    original_message.diaspora_handle = user.diaspora_handle

    user3.activate_contact(user2.person, user3.aspects.first)

    salmon_xml = user.salmon(original_message).xml_for(user3.person)
    zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
    zord.perform

    user3.reload.raw_visible_posts.should_not include(StatusMessage.find(original_message.id))
  end

  context 'malicious contact attack vector' do
    before do
      connect_users(user, aspect, user2, aspect2)
      connect_users(user, aspect, user3, aspect3)
    end

    describe 'mass assignment on id' do
      it "does not save a message over an old message with a different author" do
        original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id

        salmon_xml = user2.salmon(original_message).xml_for(user.person)

        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform

        malicious_message = Factory.build(:status_message, :id => original_message.id, :text => 'BAD!!!', :author => user3.person)
        salmon_xml = user3.salmon(malicious_message).xml_for(user.person)
        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform

        original_message.reload.text.should == "store this!"
      end

      it 'does not save a message over an old message with the same author' do
        original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id

        salmon_xml =  user2.salmon(original_message).xml_for(user.person)
        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform

        lambda {
          malicious_message = Factory.build( :status_message, :id => original_message.id, :text => 'BAD!!!', :author => user2.person)

          salmon_xml2 = user3.salmon(malicious_message).xml_for(user.person)
          zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
          zord.perform

        }.should_not change{user.reload.raw_visible_posts.count}

        original_message.reload.text.should == "store this!"
        user.raw_visible_posts.first.text.should == "store this!"
      end
    end
    it 'should not overwrite another persons profile profile' do
      profile = user2.profile.clone
      profile.first_name = "Not BOB"

      user2.reload

      first_name = user2.profile.first_name
      salmon_xml = user3.salmon(profile).xml_for(user.person)

      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      user2.reload
      user2.profile.first_name.should == first_name
    end

    it "ignores retractions on a post not owned by the retraction's sender" do
      StatusMessage.delete_all
      original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id

      salmon_xml = user2.salmon(original_message).xml_for(user.person)
      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      user.raw_visible_posts.count.should == 1
      StatusMessage.count.should == 1

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = user3.person.diaspora_handle
      ret.type = original_message.class.to_s

      salmon_xml = user3.salmon(ret).xml_for(user.person)
      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      StatusMessage.count.should == 1
      user.raw_visible_posts.count.should == 1
    end

    it "disregards retractions for non-existent posts that are from someone other than the post's author" do
      StatusMessage.delete_all
      original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id
      id = original_message.reload.id

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = user3.person.diaspora_handle
      ret.type = original_message.class.to_s

      original_message.delete

      StatusMessage.count.should == 0
      proc {
        salmon_xml = user3.salmon(ret).xml_for(user.person)
        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform
      }.should_not raise_error
    end

    it 'should not receive retractions where the retractor and the salmon author do not match' do
      original_message = user2.post :status_message, :text => 'store this!', :to => aspect2.id

      salmon_xml = user2.salmon(original_message).xml_for(user.person)
      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform


      user.raw_visible_posts.count.should == 1

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = user2.person.diaspora_handle
      ret.type = original_message.class.to_s

      lambda {

        salmon_xml = user3.salmon(ret).xml_for(user.person)
        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform

      }.should_not change(StatusMessage, :count)
      user.reload.raw_visible_posts.count.should == 1
    end

    it 'it should not allow you to send retractions for other people' do
      ret = Retraction.new
      ret.post_guid = user2.person.guid
      ret.diaspora_handle = user3.person.diaspora_handle
      ret.type = user2.person.class.to_s

      proc{
        salmon_xml = user3.salmon(ret).xml_for(user.person)

        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform

      }.should_not change{user.reload.contacts.count}
    end

    it 'it should not allow you to send retractions with xml and salmon handle mismatch' do
      ret = Retraction.new
      ret.post_guid = user2.person.guid
      ret.diaspora_handle = user2.person.diaspora_handle
      ret.type = user2.person.class.to_s

      proc{
        salmon_xml = user3.salmon(ret).xml_for(user.person)
        zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
        zord.perform
      }.should_not change{user.reload.contacts.count}
    end

    it 'does not let me update other persons post' do
      original_message = user2.post(:photo, :user_file => uploaded_photo, :text => "store this!", :to => aspect2.id)

      salmon_xml = user2.salmon(original_message).xml_for(user.person)
      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      original_message.diaspora_handle = user3.diaspora_handle
      original_message.text= "bad bad bad"

      salmon_xml = user3.salmon(original_message).xml_for(user.person)

      zord = Postzord::Receiver.new(user, :salmon_xml => salmon_xml)
      zord.perform

      original_message.reload.text.should == "store this!"
    end
  end
end
