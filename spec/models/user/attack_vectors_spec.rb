#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => 'heroes') }
  
  let(:bad_user) { Factory(:user)}

  let(:user2) { Factory(:user) }
  let(:aspect2) { user2.aspect(:name => 'losers') }

  let(:user3) { Factory(:user) }
  let(:aspect3) { user3.aspect(:name => 'heroes') }

  before do
    friend_users(user, aspect, user2, aspect2)
    friend_users(user, aspect, user3, aspect3)
  end

  context 'non-friend valid user' do
    
    it 'raises if receives post by non-friend' do
      pending "need to that posts come from friends.... requests need special treatment(because the person may not be in the db)"
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

  context 'malicious friend attack vector' do
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
      user2.profile.first_name.should == "Robert"
      proc{user.receive_salmon(user3.salmon(profile).xml_for(user.person))}.should raise_error /Malicious Post/
      user2.reload
      user2.profile.first_name.should == "Robert"
    end
    
    it 'should not overwrite another persons profile through comment' do
      pending
      user_status = user.post(:status_message, :message => "hi", :to => 'all')
      comment = Comment.new(:person_id => user3.person.id, :text => "hey", :post => user_status)
      
      comment.creator_signature = comment.sign_with_key(user3.encryption_key)
      comment.post_creator_signature = comment.sign_with_key(user.encryption_key)

      person = user3.person
      original_url = person.url
      original_id = person.id
      puts original_url
      
      comment.person.url = "http://bad.com/"
      user3.delete
      person.delete
      
      comment.to_diaspora_xml.include?("bad.com").should be true
      user2.receive_salmon(user.salmon(comment).xml_for(user2.person))
 
      comment.person.url.should == original_url
      Person.first(:id => original_id).url.should == original_url
    end
  end
end
