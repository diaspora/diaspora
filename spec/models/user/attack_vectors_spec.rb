#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe "attack vectors" do

  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'heroes') }
  
  let(:bad_user) { make_user}

  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => 'losers') }

  let(:user3) { make_user }
  let(:aspect3) { user3.aspects.create(:name => 'heroes') }

  context 'non-friend valid user' do
    
    it 'raises if receives post by non-friend' do
      post_from_non_friend = bad_user.build_post( :status_message, :message => 'hi')
      xml = bad_user.salmon(post_from_non_friend).xml_for(user.person)

      post_from_non_friend.delete
      bad_user.delete

      post_count = Post.count
      proc{ user.receive_salmon(xml) }.should raise_error /Not friends with that person/

      user.raw_visible_posts.include?(post_from_non_friend).should be false

      Post.count.should == post_count
    end

  end

  it 'does not let a user attach to posts previously in the db unless its received from the author' do
    friend_users(user, aspect, user3, aspect3)

    original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id

    original_message.diaspora_handle = user.diaspora_handle
    user3.receive_salmon(user.salmon(original_message).xml_for(user3.person))
    user3.reload.visible_posts.should_not include(original_message)
  end

  context 'malicious friend attack vector' do
    before do
      friend_users(user, aspect, user2, aspect2)
      friend_users(user, aspect, user3, aspect3)
    end


    it 'overwrites messages with a different user' do 
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id

      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      malicious_message = Factory.build( :status_message, :id => original_message.id, :message => 'BAD!!!', :person => user3.person)
      proc{user.receive_salmon(user3.salmon(malicious_message).xml_for(user.person))}.should raise_error /Malicious Post/

      user.raw_visible_posts.count.should be 1
      user.raw_visible_posts.first.message.should == "store this!"
    end
     
    it 'overwrites messages which apear to be from the same user' do 
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id
      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      malicious_message = Factory.build( :status_message, :id => original_message.id, :message => 'BAD!!!', :person => user2.person)
      proc{user.receive_salmon(user3.salmon(malicious_message).xml_for(user.person))}.should raise_error /Malicious Post/


      user.raw_visible_posts.count.should be 1
      user.raw_visible_posts.first.message.should == "store this!"
    end

    it 'should not overwrite another persons profile profile' do
      profile = user2.profile.clone
      profile.first_name = "Not BOB"

      user2.reload

      first_name = user2.profile.first_name
      proc{user.receive_salmon(user3.salmon(profile).xml_for(user.person))}.should raise_error /Malicious Post/
      user2.reload
      user2.profile.first_name.should == first_name
    end

    it 'should not receive retractions on post you do not own' do
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id
      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      ret = Retraction.new
      ret.post_id = original_message.id
      ret.diaspora_handle = user3.person.diaspora_handle
      ret.type = original_message.class.to_s

      proc{ user.receive_salmon(user3.salmon(ret).xml_for(user.person)) }.should raise_error /is trying to retract a post they do not own/
      StatusMessage.count.should be 1
      user.reload.raw_visible_posts.count.should be 1
    end

    it 'should not receive retractions where the retractor and the salmon author do not match' do
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id
      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      ret = Retraction.new
      ret.post_id = original_message.id
      ret.diaspora_handle = user2.person.diaspora_handle
      ret.type = original_message.class.to_s

      proc{ user.receive_salmon(user3.salmon(ret).xml_for(user.person)) }.should raise_error /Malicious Post/
      StatusMessage.count.should be 1
      user.reload.raw_visible_posts.count.should be 1
    end

    it 'it should not allow you to send retractions for other people' do
      ret = Retraction.new
      ret.post_id = user2.person.id
      ret.diaspora_handle = user3.person.diaspora_handle
      ret.type = user2.person.class.to_s

      proc{ 
        user.receive_salmon(user3.salmon(ret).xml_for(user.person)) 
      }.should raise_error /#{user3.diaspora_handle} trying to unfriend #{user2.person.id} from #{user.id}/
    
      user.reload.friends.count.should == 2
    end

    it 'it should not allow you to send retractions with xml and salmon handle mismatch' do
      ret = Retraction.new
      ret.post_id = user2.person.id
      ret.diaspora_handle = user2.person.diaspora_handle
      ret.type = user2.person.class.to_s

      proc{ 
        user.receive_salmon(user3.salmon(ret).xml_for(user.person)) 
      }.should raise_error /Malicious Post/
    
      user.reload.friends.count.should == 2
    end

    it 'does not let me update other persons post' do
      pending "this needs to be a photo"
      original_message = user2.post(:photo, :user_file => uploaded_photo, :caption => "store this!", :to => aspect2.id)
      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))

      original_message.diaspora_handle = user3.diaspora_handle
      original_message.caption = "bad bad bad"
      xml = user3.salmon(original_message).xml_for(user.person)
      user.receive_salmon(xml)

      original_message.reload.caption.should == "store this!"
    end
  end
end
