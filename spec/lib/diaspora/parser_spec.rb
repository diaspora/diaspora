#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspects.create(:name => 'spies')
    @user2 = Factory.create(:user)
    @aspect2 = @user2.aspects.create(:name => "pandas")
    @person = Factory.create(:person)
  end
  describe "parsing compliant XML object" do
    it 'should be able to correctly parse comment fields' do
      post = @user.post :status_message, :message => "hello", :to => @aspect.id
      comment = Factory.create(:comment, :post => post, :person => @person, :diaspora_handle => @person.diaspora_handle, :text => "Freedom!")
      comment.delete
      xml = comment.to_diaspora_xml
      comment_from_xml = Diaspora::Parser.from_xml(xml)
      comment_from_xml.diaspora_handle.should ==  @person.diaspora_handle
      comment_from_xml.post.should == post
      comment_from_xml.text.should == "Freedom!"
      comment_from_xml.should_not be comment
    end

    it 'should accept retractions' do
      connect_users(@user, @aspect, @user2, @aspect2)
      message = @user2.post(:status_message, :message => "cats", :to => @aspect2.id)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      lambda {
        @user.receive xml, @user2.person
      }.should change(StatusMessage, :count).by(-1)
    end

    context "connecting" do
      let(:good_request) { FakeHttpRequest.new(:success)}
      it "should create a new person upon getting a person request" do
        new_person = @user2.person

        request = Request.new(:recipient =>@user.person, :sender => @user2.person)
        xml = @user2.salmon(request).xml_for(@user.person)

        request.delete
        request.sender.delete
        @user2.delete
        new_person.delete
        new_person.profile.delete
        new_person = new_person.dup
        new_person.id = nil
        new_person.owner_id = nil

        Person.should_receive(:by_account_identifier).twice.and_return(new_person)

        lambda {
          @user.receive_salmon xml
        }.should change(Person, :count).by(1)
      end
    end

    it "should activate the Person if I initiated a request to that url" do
      @user.send_contact_request_to(@user2.person, @aspect)
      request = @user2.request_from(@user.person)
      fantasy_resque do
        @user2.accept_and_respond(request.id, @aspect2.id)
      end
      @user.reload
      @aspect.reload
      new_contact = @user.contact_for(@user2.person)
      @aspect.contacts.include?(new_contact).should be true
      @user.contacts.include?(new_contact).should be true
    end

    it 'should process retraction for a person' do
      connect_users(@user, @aspect, @user2, @aspect2)
      retraction = Retraction.for(@user2)
      retraction_xml = retraction.to_diaspora_xml

      lambda { @user.receive retraction_xml, @user2.person }.should change {
        @aspect.reload.contacts.size }.by(-1)
    end

    it 'should marshal a profile for a person' do
      connect_users(@user, @aspect, @user2, @aspect2)
      #Create person
      person = @user2.person
      id = person.id
      person.profile = Profile.new(:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com")
      person.save

      #Cache profile for checking against marshaled profile
      old_profile = person.profile.dup
      old_profile.first_name.should == 'bob'

      #Build xml for profile, clear profile
      xml = person.profile.to_diaspora_xml
      reloaded_person = Person.find(id)
      reloaded_person.profile = nil
      reloaded_person.save(:validate => false)

      #Make sure profile is cleared
      Person.find(id).profile.should be nil
      old_profile.first_name.should == 'bob'

      #Marshal profile
      @user.receive xml, person

      #Check that marshaled profile is the same as old profile
      person = Person.find(person.id)
      person.profile.should_not be nil
      person.profile.first_name.should == old_profile.first_name
      person.profile.last_name.should == old_profile.last_name
      person.profile.image_url.should == old_profile.image_url
    end
  end
end

