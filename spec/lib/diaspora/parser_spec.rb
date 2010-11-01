#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'spies') }
  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => "pandas") }
  let(:user3) { make_user }
  let(:person) { user3.person }

  describe "parsing compliant XML object" do
    it 'should be able to correctly parse comment fields' do
      post = user.post :status_message, :message => "hello", :to => aspect.id
      comment = Factory.create(:comment, :post => post, :person => person, :diaspora_handle => person.diaspora_handle, :text => "Freedom!")
      comment.delete
      xml = comment.to_diaspora_xml
      comment_from_xml = Diaspora::Parser.from_xml(xml)
      comment_from_xml.diaspora_handle.should ==  person.diaspora_handle
      comment_from_xml.post.should == post
      comment_from_xml.text.should == "Freedom!"
      comment_from_xml.should_not be comment
    end

    it 'should accept retractions' do
      friend_users(user, aspect, user2, aspect2)
      message = Factory.create(:status_message, :person => user2.person)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      proc { user.receive xml, user2.person }.should change(StatusMessage, :count).by(-1)
    end

    context "friending" do

    let(:good_request) { FakeHttpRequest.new(:success)}
      before do
        deliverable = Object.new
        deliverable.stub!(:deliver)
        Notifier.stub!(:new_request).and_return(deliverable)
      end

      it "should create a new person upon getting a person request" do
        new_person = Factory.build(:person) 

        Person.should_receive(:by_account_identifier).and_return(new_person)
        request = Request.instantiate(:to =>"http://www.google.com/", :from => new_person)
        xml = request.to_diaspora_xml
        user

        lambda { user.receive xml, new_person }.should change(Person, :count).by(1)
      end


    end

    it "should activate the Person if I initiated a request to that url" do
      request = user.send_friend_request_to(user3.person, aspect)
      user.reload
      request.reverse_for user3

      xml = user3.salmon(request).xml_for(user.person)

      user3.delete

      user.receive_salmon(xml)
      new_person = Person.find_by_url(user3.person.url)
      new_person.nil?.should be false

      user.reload
      aspect.reload
      new_contact = user.contact_for(new_person)
      aspect.people.include?(new_contact).should be true
      user.friends.include?(new_contact).should be true
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

