#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  let(:user) { Factory.create(:user) }
  let(:aspect) { user.aspect(:name => 'spies') }
  let(:user2) { Factory.create(:user) }
  let(:aspect2) { user2.aspect(:name => "pandas") }
  let(:user3) { Factory.create :user }
  let(:person) { user3.person }

  describe "parsing compliant XML object" do
    it 'should be able to correctly handle comments with person in db' do
      post = user.post :status_message, :message => "hello", :to => aspect.id
      comment = Factory.build(:comment, :post => post, :person => @person, :text => "Freedom!")
      xml = comment.to_diaspora_xml

      comment = Diaspora::Parser.from_xml(xml)
      comment.text.should == "Freedom!"
      comment.person.should == @person
      comment.post.should == post
    end

    it 'should be able to correctly handle person on a comment with person not in db' do
      friend_users(user, aspect, user2, aspect2)
      post = user.post :status_message, :message => "hello", :to => aspect.id
      comment = user2.comment "Fool!", :on => post

      xml = comment.to_diaspora_xml
      user2.delete
      user2.person.delete

      parsed_person = Diaspora::Parser::parse_or_find_person_from_xml(xml)
      parsed_person.save.should be true
      parsed_person.diaspora_handle.should == user2.person.diaspora_handle
      parsed_person.profile.should_not be_nil
    end

    it 'should accept retractions' do
      friend_users(user, aspect, user2, aspect2)
      message = Factory.create(:status_message, :person => user2.person)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      proc { user.receive xml, user2.person }.should change(StatusMessage, :count).by(-1)
    end

    context "friending" do
      before do
        deliverable = Object.new
        deliverable.stub!(:deliver)
        Notifier.stub!(:new_request).and_return(deliverable)
      end

      it "should create a new person upon getting a person request" do
        request = Request.instantiate(:to =>"http://www.google.com/", :from => person)

        xml = request.to_diaspora_xml

        user3.destroy
        person.destroy
        user
        lambda { user.receive xml, person }.should change(Person, :count).by(1)
      end

      it "should not create a new person if the person is already here" do
        request = Request.instantiate(:to =>"http://www.google.com/", :from => user2.person)
        original_person_id = user2.person.id
        xml = request.to_diaspora_xml
        user
        lambda { user.receive xml, user2.person }.should_not change(Person, :count)

        user2.reload
        user2.person.reload
        user2.serialized_private_key.include?("PRIVATE").should be true

        url = "http://" + request.callback_url.split("/")[2] + "/"
        Person.where(:url => url).first.id.should == original_person_id
      end
    end

    it "should activate the Person if I initiated a request to that url" do
      request = user.send_friend_request_to(user3.person, aspect)
      user.reload
      request.reverse_for user3

      xml = request.to_diaspora_xml

      user3.person.destroy
      user3.destroy

      user.receive xml, user3.person
      new_person = Person.first(:url => user3.person.url)
      new_person.nil?.should be false

      user.reload
      aspect.reload
      aspect.people.include?(new_person).should be true
      user.friends.include?(new_person).should be true
    end

    it 'should process retraction for a person' do
      friend_users(user, aspect, user2, aspect2)
      retraction = Retraction.for(user2)
      retraction_xml = retraction.to_diaspora_xml

      lambda { user.receive retraction_xml, user2.person }.should change {
        aspect.reload.people.size }.by(-1)
    end

    it 'should marshal a profile for a person' do
      friend_users(user, aspect, user2, aspect2)
      #Create person
      person = user2.person
      id = person.id
      person.profile = Profile.new(:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com")
      person.save

      #Cache profile for checking against marshaled profile
      old_profile = person.profile.dup
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
      user.receive xml, person

      #Check that marshaled profile is the same as old profile
      person = Person.first(:id => person.id)
      person.profile.should_not be nil
      person.profile.first_name.should == old_profile.first_name
      person.profile.last_name.should == old_profile.last_name
      person.profile.image_url.should == old_profile.image_url
    end
  end
end

