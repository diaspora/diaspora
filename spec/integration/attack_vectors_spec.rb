#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


def receive(post, opts)
  sender = opts.fetch(:from)
  receiver = opts.fetch(:by)
  salmon_xml = sender.salmon(post).xml_for(receiver.person)
  zord = Postzord::Receiver::Private.new(receiver, :salmon_xml => salmon_xml)
  zord.perform!
end

def receive_public(post, opts)
  sender = opts.fetch(:from)
  salmon_xml = Salmon::Slap.create_by_user_and_activity(sender, post.to_diaspora_xml).xml_for(nil)
  post.destroy
  zord = Postzord::Receiver::Public.new(salmon_xml)
  zord.perform!
end

def temporary_user(&block)
  user = FactoryGirl.create(:user)
  block_return_value = yield user
  user.delete
  block_return_value
end

def temporary_post(user, &block)
  temp_post = user.post(:status_message, :text => 'hi')
  block_return_value = yield temp_post
  temp_post.delete
  block_return_value
end

def expect_error(partial_message, &block)# DOES NOT REQUIRE ERROR!!
  begin 
    yield
  rescue => e
    e.message.should match partial_message

  ensure
    raise "no error occured where expected" unless e.present?
  end
end

def bogus_retraction(&block)
  ret = Retraction.new
  yield ret
  ret
end

def user_should_not_see_guid(user, guid)
 user.reload.visible_shareables(Post).where(:guid => guid).should be_blank
end
    #returns the message
def legit_post_from_user1_to_user2(user1, user2)
  original_message = user1.post(:status_message, :text => 'store this!', :to => user1.aspects.find_by_name("generic").id)
  receive(original_message, :from => user1, :by => user2)
  original_message
end

describe "attack vectors" do

  let(:eves_aspect) { eve.aspects.find_by_name("generic") }
  let(:alices_aspect) { alice.aspects.find_by_name("generic") }

  context "testing side effects of validation phase" do

    describe 'Contact Required Unless Request' do
      #CUSTOM SETUP; cant use helpers here
      it 'does not save a post from a non-contact as a side effect' do
        salmon_xml = nil
        bad_post_guid = nil

        temporary_user do |bad_user|
          temporary_post(bad_user) do |post_from_non_contact|
            bad_post_guid = post_from_non_contact.guid
            salmon_xml = bad_user.salmon(post_from_non_contact).xml_for(bob.person)
          end
        end

        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)

        expect {
          expect_error /Contact required/ do
            zord.perform!
          end
        }.to_not change(Post, :count)

        user_should_not_see_guid(bob, bad_post_guid)
      end


      #CUSTOM SETUP; cant use helpers here
      it 'other users can not grant visiblity to another users posts by sending their friends post to themselves (even if they are contacts)' do
        #setup: eve has a message. then, alice is connected to eve.
        #(meaning alice can not see the old post, but it exists in the DB)
        # bob takes eves message, changes the post author to himself
        # bob trys to send a message to alice
        original_message = eve.post(:status_message, :text => 'store this!', :to => eves_aspect.id)
        original_message.diaspora_handle = bob.diaspora_handle

        alice.contacts.create(:person => eve.person, :aspects => [alice.aspects.first])

        salmon_xml = bob.salmon(original_message).xml_for(alice.person)

        #bob sends it to himself?????
        zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)

        expect_error /Contact required/ do
          zord.perform!
        end

        #alice still should not see eves original post, even though bob sent it to her
        user_should_not_see_guid(alice, original_message.guid)
      end
    end

    describe 'author does not match xml author' do
      it 'should not overwrite another persons profile profile' do
        profile = eve.profile.clone
        profile.first_name = "Not BOB"

        expect {
          expect_error /Author does not match XML author/ do
            receive(profile, :from => alice, :by => bob)
          end
        }.to_not change(eve.profile, :first_name) 
      end
    end


    it 'public stuff should not be spoofed from another author' do
      post = FactoryGirl.build(:status_message, :public => true, :author => eve.person)
      expect_error /Author does not match XML author/ do
        receive_public(post, :from => alice)
      end
    end
  end



  context 'malicious contact attack vector' do
    describe 'mass assignment on id' do
      it "does not save a message over an old message with a different author" do
        #setup:  A user has a message with a given guid and author
        original_message = legit_post_from_user1_to_user2(eve, bob)

        #someone else tries to make a message with the same guid
        malicious_message = FactoryGirl.build(:status_message, :id => original_message.id, :guid => original_message.guid, :author => alice.person)

        expect{
          receive(malicious_message, :from => alice, :by => bob)
        }.to_not change(original_message, :author_id)
      end

      it 'does not save a message over an old message with the same author' do
        #setup:
        # i have a legit message from eve
        original_message = legit_post_from_user1_to_user2(eve, bob)

        #eve tries to send me another message with the same ID
        malicious_message = FactoryGirl.build( :status_message, :id => original_message.id, :text => 'BAD!!!', :author => eve.person)

        expect {
          receive(malicious_message, :from => eve, :by => bob)
        }.to_not change(original_message, :text)
      end
    end


    it "ignores retractions on a post not owned by the retraction's sender" do
      original_message = legit_post_from_user1_to_user2(eve, bob)

      ret = bogus_retraction do |retraction| 
        retraction.post_guid = original_message.guid
        retraction.diaspora_handle = alice.person.diaspora_handle
        retraction.type = original_message.class.to_s
      end

      expect {
        receive(ret, :from => alice, :by => bob)
      }.to_not change(StatusMessage, :count)
    end

    it "silently disregards retractions for non-existent posts(that are from someone other than the post's author)" do
      bogus_retraction = temporary_post(eve) do |original_message|
                            bogus_retraction do |ret|
                              ret.post_guid = original_message.guid
                              ret.diaspora_handle = alice.person.diaspora_handle
                              ret.type = original_message.class.to_s
                            end
                          end
       expect{
        receive(bogus_retraction, :from => alice, :by => bob)
      }.to_not raise_error
    end

    it 'should not receive retractions where the retractor and the salmon author do not match' do
      original_message = legit_post_from_user1_to_user2(eve, bob)

      retraction = bogus_retraction do |ret|
        ret.post_guid = original_message.guid
        ret.diaspora_handle = eve.person.diaspora_handle
        ret.type = original_message.class.to_s
      end

      expect {
        expect_error /Author does not match XML author/  do
          receive(retraction, :from => alice, :by => bob)
        end
      }.to_not change(bob.visible_shareables(Post), :count)

    end

    it 'it should not allow you to send retractions for other people' do
      #we are banking on bob being friends with alice and eve
      #here, alice is trying to disconnect bob and eve

      retraction = bogus_retraction do |ret|
        ret.post_guid = eve.person.guid
        ret.diaspora_handle = alice.person.diaspora_handle
        ret.type = eve.person.class.to_s
      end

      expect{
        receive(retraction, :from => alice, :by => bob)
      }.to_not change{bob.reload.contacts.count}
    end

    it 'it should not allow you to send retractions with xml and salmon handle mismatch' do
      retraction = bogus_retraction do |ret|
        ret.post_guid = eve.person.guid
        ret.diaspora_handle = eve.person.diaspora_handle
        ret.type = eve.person.class.to_s
      end

      expect{
        expect_error /Author does not match XML author/ do
          receive(retraction, :from => alice, :by => bob)
        end
        }.to_not change(bob.contacts, :count)
    end

    it 'does not let another user update other persons post' do
      original_message = eve.post(:photo, :user_file => uploaded_photo, :text => "store this!", :to => eves_aspect.id)
      receive(original_message, :from => eve, :by => bob)

      #is this testing two things?
      new_message = original_message.dup
      new_message.diaspora_handle = alice.diaspora_handle
      new_message.text = "bad bad bad"

      expect{
        receive(new_message, :from => alice, :by => bob)
       }.to_not change(original_message, :text)
    end
  end
end
