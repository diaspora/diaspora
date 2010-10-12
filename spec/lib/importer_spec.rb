#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/diaspora/exporter')
require File.join(Rails.root, 'lib/diaspora/importer')

describe Diaspora::Importer do

  # Five users on pod
  let!(:user1) { Factory(:user) }
  let!(:user2) { Factory(:user) }
  let!(:user3) { Factory(:user) }
  let!(:user4) { Factory(:user) }
  let!(:user5) { Factory(:user) }

  # Two external people referenced on pod
  let!(:person1) { Factory(:person) }
  let!(:person2) { Factory(:person) }

  # User1 has four aspects(1-4), each following user has one aspect
  let!(:aspect1) { user1.aspect(:name => "Dudes")   }
  let!(:aspect2) { user1.aspect(:name => "Girls") }
  let!(:aspect3) { user1.aspect(:name => "Bros") }
  let!(:aspect4) { user1.aspect(:name => "People") }
  let!(:aspect5) { user2.aspect(:name => "Abe Lincolns") }
  let!(:aspect6) { user3.aspect(:name => "Cats") }
  let!(:aspect7) { user4.aspect(:name => "Dogs") }
  let!(:aspect8) { user5.aspect(:name => "Hamsters") }

  # User1 posts one status messages to aspects (1-4), two other users post message to one aspect
  let(:status_message1) { user1.post(:status_message, :message => "One", :public => true, :to => aspect1.id) }
  let(:status_message2) { user1.post(:status_message, :message => "Two", :public => true, :to => aspect2.id) }
  let(:status_message3) { user1.post(:status_message, :message => "Three", :public => false, :to => aspect3.id) }
  let(:status_message4) { user1.post(:status_message, :message => "Four", :public => false, :to => aspect4.id) }
  let(:status_message5) { user2.post(:status_message, :message => "Five", :public => false, :to => aspect5.id) }
  let(:status_message6) { user3.post(:status_message, :message => "Six", :public => false, :to => aspect6.id) }

  before(:all) do
    # Friend users
    friend_users( user1, aspect1, user2, aspect5 )
    friend_users( user1, aspect2, user3, aspect6 )
    friend_users( user1, aspect3, user4, aspect7 )
    friend_users( user1, aspect4, user5, aspect8 )

    # Generate status messages and receive
    user2.receive status_message1.to_diaspora_xml
    user3.receive status_message2.to_diaspora_xml
    user4.receive status_message3.to_diaspora_xml
    user5.receive status_message4.to_diaspora_xml
    user1.receive status_message5.to_diaspora_xml
    user1.receive status_message6.to_diaspora_xml
  end

  it 'should gut check this test' do 
    user1.friends.count.should be 4
    user1.friends.should include user2.person
    user1.friends.should include user3.person
    user1.friends.should include user4.person
    user1.friends.should include user5.person
    
    # User is generated with two pre-populated aspects
    user1.aspects.count.should be 6
    user1.aspects.find_by_name("Dudes").people.should include user2.person
    user1.aspects.find_by_name("Dudes").posts.should include status_message5
    
    user1.raw_visible_posts.count.should be 6
    user1.raw_visible_posts.find_all_by_person_id(user1.person.id).count.should be 4
  end

end

