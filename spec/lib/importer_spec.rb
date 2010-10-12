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
  let!(:aspect9) { user5.aspect(:name => "Gophers") }

  # User1 posts one status messages to aspects (1-4), two other users post message to one aspect
  let(:status_message1) { user1.post(:status_message, :message => "One", :public => true, :to => aspect1.id) }
  let(:status_message2) { user1.post(:status_message, :message => "Two", :public => true, :to => aspect2.id) }
  let(:status_message3) { user1.post(:status_message, :message => "Three", :public => false, :to => aspect3.id) }
  let(:status_message4) { user1.post(:status_message, :message => "Four", :public => false, :to => aspect4.id) }
  let(:status_message5) { user2.post(:status_message, :message => "Five", :public => false, :to => aspect5.id) }
  let(:status_message6) { user3.post(:status_message, :message => "Six", :public => false, :to => aspect6.id) }
  let(:status_message7) { user5.post(:status_message, :message => "Seven", :public => false, :to => aspect9.id) }

  before(:all) do
    # Friend users with user1
    friend_users( user1, aspect1, user2, aspect5 )
    friend_users( user1, aspect2, user3, aspect6 )
    friend_users( user1, aspect3, user4, aspect7 )
    friend_users( user1, aspect4, user5, aspect8 )

    # Friend users 4 and 5
    friend_users( user5, aspect9, user4, aspect7 )

    # Generate status messages and receive for user1
    user2.receive status_message1.to_diaspora_xml
    user3.receive status_message2.to_diaspora_xml
    user4.receive status_message3.to_diaspora_xml
    user5.receive status_message4.to_diaspora_xml
    user1.receive status_message5.to_diaspora_xml
    user1.receive status_message6.to_diaspora_xml

    # Generate status message and recieve between user4 and user5
    user4.receive status_message7.to_diaspora_xml
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
    user1.raw_visible_posts.find_all_by_person_id(user1.person.id).should_not include status_message7
  end

  context 'importing a user' do

    before(:all) do
      # Generate exported XML for user1
      exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
      @xml = exporter.execute(user1)

      @old_user = user1
      @old_aspects = user1.aspects
      # Remove user1 from the server
      user1.aspects.each( &:delete )
      user1.raw_visible_posts.find_all_by_person_id(user1.person.id).each( &:delete )
      user1.delete

      @importer = Diaspora::Importer.new(Diaspora::Importers::XML)
      @doc = Nokogiri::XML::parse(@xml)
    end

    it 'should import a user' do
      user = @importer.execute(@xml)
      user.class.should == User
    end

    describe '#parse_user' do
      before do
        @user, @person = @importer.parse_user(@doc)
      end

      it 'should set username' do
        @user.username.should == @old_user.username
      end

      it 'should set private key' do
        @user.serialized_private_key.should_not be nil
        @user.serialized_private_key.should == @old_user.serialized_private_key
      end

      it 'should ensure a match between persons public and private keys' do
        pending
      end
    end
    
    describe '#parse_aspects' do
      before do
        @aspects = @importer.parse_aspects(@doc)
      end

      it 'should return valid aspects' do 
        @aspects.all?(&:valid?).should be true
      end

      it 'should return an array' do
        @aspects.count.should == 6
      end

      it 'should should have post ids' do
        @aspects.any?{|x| x.post_ids.count > 0}.should be true
      end

      it 'should have person ids' do
        @aspects.any?{|x| x.person_ids.count > 0}.should be true
      end
    end

    describe '#parse_people' do
      before do
        @people = @importer.parse_people(@doc)
      end

      it 'should return valid people' do 
        @people.all?(&:valid?).should be true
      end

      it 'should return an array' do
        @people.count.should == 4 
      end
    end



    describe '#parse_posts' do
      it 'should have a users personal posts' do 
        pending
        @user.raw_visible_posts.find_all_by_person_id(user1.person.id).count.should be 4
      end
    end

  
  end

end

