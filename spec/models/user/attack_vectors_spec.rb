#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => 'heroes') }

  let(:user2) { Factory(:user) }
  let(:aspect2) { user2.aspect(:name => 'losers') }

  let(:user3) { Factory(:user) }
  let(:aspect3) { user3.aspect(:name => 'heroes') }

  before do
    friend_users(user, aspect, user2, aspect2)
    friend_users(user, aspect, user3, aspect3)
  end

  context 'malicious friend attack vector' do
    it 'ovewrites messages with a different user' do 
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id

      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      malicious_message = Factory.build( :status_message, :id => original_message.id, :message => 'BAD!!!', :person => user3.person)
      user.receive_salmon(user3.salmon(malicious_message).xml_for(user.person))

      user.raw_visible_posts.count.should be 1
      user.raw_visible_posts.first.message.should == "store this!"
    end
     
    it 'ovewrites messages which apear to ' do 
      original_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id
      user.receive_salmon(user2.salmon(original_message).xml_for(user.person))
      user.raw_visible_posts.count.should be 1

      malicious_message = Factory.build( :status_message, :id => original_message.id, :message => 'BAD!!!', :person => user2.person)
      user.receive_salmon(user3.salmon(malicious_message).xml_for(user.person))

      user.raw_visible_posts.count.should be 1
      user.raw_visible_posts.first.message.should == "store this!"
    end

    it 'overites another persons profile' do 
      profile = user2.profile.clone
      profile.first_name = "Not BOB"

      user2.reload
      user2.profile.first_name.should == "Robert"
      user.receive_salmon(user3.salmon(profile).xml_for(user.person))
      user2.reload
      user2.profile.first_name.should == "Robert"
    end

    it 'overwrites requests' do
      pending
    end
  end
end
