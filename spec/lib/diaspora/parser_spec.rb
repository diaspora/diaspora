#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  before do
    @user1 = alice
    @user2 = bob
    @user3 = eve

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first
    @aspect3 = @user3.aspects.first

    @person = Factory.create(:person)
  end

  describe "parsing compliant XML object" do
    it 'should be able to correctly parse comment fields' do
      post = @user1.post :status_message, :message => "hello", :to => @aspect1.id
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
      message = @user2.post(:status_message, :message => "cats", :to => @aspect2.id)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      lambda {
        zord = Postzord::Receiver.new(@user1, :person => @user2.person)
        zord.parse_and_receive(xml)
       }.should change(StatusMessage, :count).by(-1)
    end

    it "should activate the Person if I initiated a request to that url" do
      begin
      @user1.send_contact_request_to(@user3.person, @aspect1)
      rescue Exception => e
        raise e.original_exception
      end
      request = @user3.request_from(@user1.person)
      fantasy_resque do
        @user3.accept_and_respond(request.id, @aspect3.id)
      end
      @user1.reload
      @aspect1.reload
      new_contact = @user1.contact_for(@user3.person)
      @aspect1.contacts.include?(new_contact).should be true
      @user1.contacts.include?(new_contact).should be true
    end

    it 'should process retraction for a person' do
      retraction = Retraction.for(@user2)
      retraction_xml = retraction.to_diaspora_xml

      lambda {
          zord = Postzord::Receiver.new(@user1, :person => @user2.person)
          zord.parse_and_receive(retraction_xml)
      }.should change {
        @aspect1.contacts(true).size }.by(-1)
    end

    it 'should marshal a profile for a person' do
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
      reloaded_person.profile.delete
      reloaded_person.save(:validate => false)

      #Make sure profile is cleared
      Person.find(id).profile.should be nil
      old_profile.first_name.should == 'bob'

      #Marshal profile
      zord = Postzord::Receiver.new(@user1, :person => person)
      zord.parse_and_receive(xml)

      #Check that marshaled profile is the same as old profile
      person = Person.find(person.id)
      person.profile.should_not be nil
      person.profile.first_name.should == old_profile.first_name
      person.profile.last_name.should == old_profile.last_name
      person.profile.image_url.should == old_profile.image_url
    end
  end
end

