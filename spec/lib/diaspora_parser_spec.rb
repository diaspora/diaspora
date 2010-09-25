#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @aspect = @user.aspect(:name => 'spies')
    @person = Factory.create(:person_with_private_key, :diaspora_handle => "bill@gates.com")
    @user2 = Factory.create(:user)
  end

  describe "parsing compliant XML object" do
    before do
      @xml = Factory.build(:status_message).to_diaspora_xml
    end

     it 'should be able to correctly handle comments with person in db' do
      person = Factory.create(:person, :diaspora_handle => "test@testing.com")
      post = Factory.create(:status_message, :person => @user.person)
      comment = Factory.build(:comment, :post => post, :person => person, :text => "Freedom!")
      xml = comment.to_diaspora_xml

      comment = Diaspora::Parser.from_xml(xml)
      comment.text.should == "Freedom!"
      comment.person.should == person
      comment.post.should == post
    end

    it 'should be able to correctly handle person on a comment with person not in db' do
      commenter = Factory.create(:user)
      commenter_aspect = commenter.aspect :name => "bruisers"
      friend_users(@user, @aspect, commenter, commenter_aspect)
      post = @user.post :status_message, :message => "hello", :to => @aspect.id
      comment = commenter.comment "Fool!", :on => post

      xml = comment.to_diaspora_xml
      commenter.delete
      commenter.person.delete

      parsed_person = Diaspora::Parser::parse_or_find_person_from_xml(xml)
      parsed_person.save.should be true
      parsed_person.diaspora_handle.should == commenter.person.diaspora_handle
      parsed_person.profile.should_not be_nil
    end

    it 'should marshal retractions' do
      person = Factory.create(:person)
      message = Factory.create(:status_message, :person => person)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      StatusMessage.count.should == 1
      @user.receive xml
      StatusMessage.count.should == 0
    end

    it "should create a new person upon getting a person request" do
      person_count = Person.all.count
      request = Request.instantiate(:to =>"http://www.google.com/", :from => @person)

      original_person_id = @person.id
      xml = request.to_diaspora_xml

      @person.destroy
      Person.all.count.should == person_count -1
      @user.receive xml
      Person.all.count.should == person_count

      Person.first(:_id => original_person_id).serialized_key.include?("PUBLIC").should be true
      url = "http://" + request.callback_url.split("/")[2] + "/"
      Person.where(:url => url).first.id.should == original_person_id
    end

    it "should not create a new person if the person is already here" do
      person_count = Person.all.count
      request = Request.instantiate(:to =>"http://www.google.com/", :from => @user2.person)

      original_person_id = @user2.person.id
      xml = request.to_diaspora_xml

      Person.all.count.should be person_count
      @user.receive xml
      Person.all.count.should be person_count

      @user2.reload
      @user2.person.reload
      @user2.person.serialized_key.include?("PRIVATE").should be true

      url = "http://" + request.callback_url.split("/")[2] + "/"
      Person.where(:url => url).first.id.should == original_person_id
    end

    it "should activate the Person if I initiated a request to that url" do
      request = @user.send_friend_request_to( @user2.person, @aspect)
      @user.reload
      request.reverse_for @user2

      xml = request.to_diaspora_xml

      @user2.person.destroy
      @user2.destroy

      @user.receive xml
      new_person = Person.first(:url => @user2.person.url)
      new_person.nil?.should be false

      @user.reload
      @aspect.reload
      @aspect.people.include?(new_person).should be true
      @user.friends.include?(new_person).should be true
    end

    it 'should process retraction for a person' do
      person_count = Person.all.count
      request = @user.send_friend_request_to( @user2.person, @aspect)
      @user.reload
      request.reverse_for @user2
      xml = request.to_diaspora_xml

      retraction = Retraction.for(@user2)
      retraction_xml = retraction.to_diaspora_xml

      @user2.person.destroy
      @user2.destroy
      @user.receive xml

      @aspect.reload
      aspect_people_count = @aspect.people.size
      #They are now friends

      Person.count.should == person_count
      @user.receive retraction_xml

      @aspect.reload
      @aspect.people.size.should == aspect_people_count -1
    end

    it 'should marshal a profile for a person' do
      #Create person
      person = Factory.create(:person)
      id = person.id
      person.profile = Profile.new(:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com")
      person.save

      #Cache profile for checking against marshaled profile
      old_profile = person.profile
      old_profile.first_name.should == 'bob'

      #Build xml for profile, clear profile
      xml = person.profile.to_diaspora_xml
      reloaded_person = Person.first(:id => id)
      reloaded_person.profile = nil
      reloaded_person.save(:validate => false)

      #Make sure profile is cleared
      Person.first(:id => id).profile.should be nil
      old_profile.first_name.should == 'bob'

      #Marshal profile
      @user.receive xml

      #Check that marshaled profile is the same as old profile
      person = Person.first(:id => person.id)
      person.profile.should_not be nil
      person.profile.first_name.should == old_profile.first_name
      person.profile.last_name.should  == old_profile.last_name
      person.profile.image_url.should  == old_profile.image_url
      end
  end
end

