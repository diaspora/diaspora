#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Person do
  before do
    @user = Factory.create(:user)
    @user2 = Factory.create(:user)
    @person = Factory.create(:person)
    @aspect = @user.aspect(:name => "Dudes")
    @aspect2 = @user2.aspect(:name => "Abscence of Babes")
  end

  describe '#diaspora_handle' do
    it 'should downcase and strip the handle before it saves' do
      p = Factory.build(:person, :diaspora_handle => "  FOOBaR@example.com  ")
      p.save
      p.diaspora_handle.should == "foobar@example.com"
    end
    context 'local people' do
      it 'uses the pod config url to set the diaspora_handle' do
        @user.person.diaspora_handle.should == @user.username + "@" + APP_CONFIG[:terse_pod_url]
      end
    end

    context 'remote people' do
      it 'stores the diaspora_handle in the database' do
        @person.diaspora_handle.include?(APP_CONFIG[:terse_pod_url]).should be false
      end
    end
  end

  it 'should not allow two people with the same diaspora_handle' do
    person_two = Factory.build(:person, :url => @person.diaspora_handle)
    person_two.valid?.should == false
  end

    describe 'xml' do
    before do
      @xml = @person.to_xml.to_s
    end

    it 'should serialize to xml' do
      @xml.include?("person").should == true
    end

    it 'should have a profile in its xml' do
      @xml.include?("first_name").should == true

    end
  end

  it 'should know when a post belongs to it' do
    person_message = Factory.create(:status_message, :person => @person)
    person_two =     Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  it 'should delete all of user posts except comments upon user deletion' do
    person = Factory.create(:person)

    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)

    status_message = Factory.create(:status_message, :person => @person)

    Factory.create(:comment, :person_id => person.id,  :text => "yes i do",       :post => status_message)
    Factory.create(:comment, :person_id => person.id,  :text => "i love you",     :post => status_message)
    Factory.create(:comment, :person_id => person.id,  :text => "hello",          :post => status_message)
    Factory.create(:comment, :person_id => @person.id, :text => "you are creepy", :post => status_message)

    person.destroy

    Post.count.should == 1
    Comment.all.count.should == 4
    status_message.comments.count.should == 4
  end

  describe "unfriending" do
    it 'should not delete an orphaned friend' do
      request = @user.send_friend_request_to @person, @aspect

      @user.activate_friend(@person, @aspect)
      @user.reload

      Person.all.count.should    == 3
      @user.friends.count.should == 1
      @user.unfriend(@person)
      @user.reload
      @user.friends.count.should == 0
      Person.all.count.should    == 3
    end

    it 'should not delete an un-orphaned friend' do
      request = @user.send_friend_request_to @person, @aspect
      request2 = @user2.send_friend_request_to @person, @aspect2

      @user.activate_friend(@person, @aspect)
      @user2.activate_friend(@person, @aspect2)

      @user.reload
      @user2.reload

      Person.all.count.should     == 3
      @user.friends.count.should  == 1
      @user2.friends.count.should == 1

      @user.unfriend(@person)
      @user.reload
      @user2.reload
      @user.friends.count.should  == 0
      @user2.friends.count.should == 1

      Person.all.count.should     == 3
    end
  end

  describe '::search' do
    before do
      @friend_one   = Factory.create(:person)
      @friend_two   = Factory.create(:person)
      @friend_three = Factory.create(:person)
      @friend_four  = Factory.create(:person)

      @friend_one.profile.first_name = "Robert"
      @friend_one.profile.last_name  = "Grimm"
      @friend_one.profile.save

      @friend_two.profile.first_name = "Eugene"
      @friend_two.profile.last_name  = "Weinstein"
      @friend_two.save

      @friend_three.profile.first_name = "Yevgeniy"
      @friend_three.profile.last_name  = "Dodis"
      @friend_three.save

      @friend_four.profile.first_name = "Casey"
      @friend_four.profile.last_name  = "Grippi"
      @friend_four.save
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eu")
      people.include?(@friend_two).should   == true
      people.include?(@friend_one).should   == false
      people.include?(@friend_three).should == false
      people.include?(@friend_four).should  == false

      people = Person.search("wEi")
      people.include?(@friend_two).should   == true
      people.include?(@friend_one).should   == false
      people.include?(@friend_three).should == false
      people.include?(@friend_four).should  == false

      people = Person.search("gri")
      people.include?(@friend_one).should   == true
      people.include?(@friend_four).should  == true
      people.include?(@friend_two).should   == false
      people.include?(@friend_three).should == false
    end

    it 'should yield results on full names' do
      people = Person.search("Casey Grippi")
      people.should == [@friend_four]
    end
  end

  describe ".by_webfinger" do
    context "local people" do
      before do
        @local_person = Factory(:person)
        Redfinger.should_not_receive :finger
      end

      it "finds the local person without calling out" do
        person = Person.by_webfinger(@local_person.diaspora_handle)
        person.should == @local_person
      end

      it "finds a local person with a mixed-case username" do
        user = Factory(:user, :username => "SaMaNtHa")
        person = Person.by_webfinger(user.person.diaspora_handle)
        person.should == user.person
      end
    end

    it 'creates a stub for a remote user' do
      stub_success("tom@tom.joindiaspora.com")
      tom = Person.by_webfinger('tom@tom.joindiaspora.com')
      tom.real_name.include?("Hamiltom").should be true
    end
  end
end
