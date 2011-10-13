#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe "attack vectors" do

  let(:eves_aspect) { eve.aspects.find_by_name("generic") }
  let(:alices_aspect) { alice.aspects.find_by_name("generic") }

  context 'non-contact valid user' do
    it 'does not save a post from a non-contact' do
      bad_user = Factory(:user)

      post_from_non_contact = bad_user.build_post( :status_message, :text => 'hi')
      salmon_xml = bad_user.salmon(post_from_non_contact).xml_for(bob.person)

      post_from_non_contact.delete
      bad_user.delete
      post_count = Post.count

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      expect {
        zord.perform!
      }.should raise_error /not a valid object/

      bob.visible_shareables(Post).include?(post_from_non_contact).should be_false
      Post.count.should == post_count
    end
  end

  it 'does not let a user attach to posts previously in the db unless its received from the author' do
    original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id
    original_message.diaspora_handle = bob.diaspora_handle

    alice.contacts.create(:person => eve.person, :aspects => [alice.aspects.first])

    salmon_xml = bob.salmon(original_message).xml_for(alice.person)
    zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
    expect {
      zord.perform!
    }.should raise_error /not a valid object/

    alice.reload.visible_shareables(Post).should_not include(StatusMessage.find(original_message.id))
  end

  context 'malicious contact attack vector' do
    describe 'mass assignment on id' do
      it "does not save a message over an old message with a different author" do
        original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id

        salmon_xml = eve.salmon(original_message).xml_for(bob.person)

        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
        zord.perform!

        malicious_message = Factory.build(:status_message, :id => original_message.id, :text => 'BAD!!!', :author => alice.person)
        salmon_xml = alice.salmon(malicious_message).xml_for(bob.person)
        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
        zord.perform!

        original_message.reload.text.should == "store this!"
      end

      it 'does not save a message over an old message with the same author' do
        original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id

        salmon_xml =  eve.salmon(original_message).xml_for(bob.person)
        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
        zord.perform!

        lambda {
          malicious_message = Factory.build( :status_message, :id => original_message.id, :text => 'BAD!!!', :author => eve.person)

          salmon_xml2 = alice.salmon(malicious_message).xml_for(bob.person)
          zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
          zord.perform!

        }.should_not change{
          bob.reload.visible_shareables(Post).count
        }

        original_message.reload.text.should == "store this!"
        bob.visible_shareables(Post).first.text.should == "store this!"
      end
    end

    it 'should not overwrite another persons profile profile' do
      profile = eve.profile.clone
      profile.first_name = "Not BOB"

      eve.reload

      first_name = eve.profile.first_name
      salmon_xml = alice.salmon(profile).xml_for(bob.person)

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      expect {
        zord.perform!
      }.should raise_error /not a valid object/

      eve.reload.profile.first_name.should == first_name
    end

    it "ignores retractions on a post not owned by the retraction's sender" do
      StatusMessage.delete_all
      original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id

      salmon_xml = eve.salmon(original_message).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      bob.visible_shareables(Post).count.should == 1
      StatusMessage.count.should == 1

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = alice.person.diaspora_handle
      ret.type = original_message.class.to_s

      salmon_xml = alice.salmon(ret).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      StatusMessage.count.should == 1
      bob.visible_shareables(Post).count.should == 1
    end

    it "disregards retractions for non-existent posts that are from someone other than the post's author" do
      StatusMessage.delete_all
      original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id
      id = original_message.reload.id

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = alice.person.diaspora_handle
      ret.type = original_message.class.to_s

      original_message.delete

      StatusMessage.count.should == 0
      proc {
        salmon_xml = alice.salmon(ret).xml_for(bob.person)
        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
        zord.perform!
      }.should_not raise_error
    end

    it 'should not receive retractions where the retractor and the salmon author do not match' do
      original_message = eve.post :status_message, :text => 'store this!', :to => eves_aspect.id

      salmon_xml = eve.salmon(original_message).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      bob.visible_shareables(Post).count.should == 1

      ret = Retraction.new
      ret.post_guid = original_message.guid
      ret.diaspora_handle = eve.person.diaspora_handle
      ret.type = original_message.class.to_s

      salmon_xml = alice.salmon(ret).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      expect {
        zord.perform!
      }.should raise_error /not a valid object/

      bob.reload.visible_shareables(Post).count.should == 1
    end

    it 'it should not allow you to send retractions for other people' do
      ret = Retraction.new
      ret.post_guid = eve.person.guid
      ret.diaspora_handle = alice.person.diaspora_handle
      ret.type = eve.person.class.to_s

      proc{
        salmon_xml = alice.salmon(ret).xml_for(bob.person)

        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
        zord.perform!

      }.should_not change{bob.reload.contacts.count}
    end

    it 'it should not allow you to send retractions with xml and salmon handle mismatch' do
      ret = Retraction.new
      ret.post_guid = eve.person.guid
      ret.diaspora_handle = eve.person.diaspora_handle
      ret.type = eve.person.class.to_s

      bob.contacts.count.should == 2

      salmon_xml = alice.salmon(ret).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      expect {
        zord.perform!
      }.should raise_error /not a valid object/

      bob.reload.contacts.count.should == 2
    end

    it 'does not let me update other persons post' do
      original_message = eve.post(:photo, :user_file => uploaded_photo, :text => "store this!", :to => eves_aspect.id)

      salmon_xml = eve.salmon(original_message).xml_for(bob.person)
      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      original_message.diaspora_handle = alice.diaspora_handle
      original_message.text= "bad bad bad"

      salmon_xml = alice.salmon(original_message).xml_for(bob.person)

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      original_message.reload.text.should == "store this!"
    end
  end
end
