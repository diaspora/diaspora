require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @group = @user.group(:name => 'heroes')
   end

  describe 'friend requesting' do
    it "should assign a request to a group" do
      friend = Factory.create(:person)
      group = @user.group(:name => "Dudes")
      group.requests.size.should == 0

      @user.send_friend_request_to(friend, group)

      group.reload
      group.requests.size.should == 1
    end


     it "should be able to accept a pending friend request" do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => @user.receive_url, :from => friend)
      r.save
      Person.all.count.should == 2
      Request.for_user(@user).all.count.should == 1
      @user.accept_friend_request(r.id, @group.id)
      Request.for_user(@user).all.count.should == 0
    end

    it 'should be able to ignore a pending friend request' do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => @user.receive_url, :from => friend)
      r.save

      Person.count.should == 2

      @user.ignore_friend_request(r.id)

      Person.count.should == 1
      Request.count.should == 0
    end

    it 'should not be able to friend request an existing friend' do friend = Factory.create(:person)
      
      @user.friends << friend
      @user.save


      proc {@user.send_friend_request_to( friend, @group)}.should raise_error
    end



    describe 'multiple users accepting/rejecting the same person' do
      before do
        @person_one = Factory.create :person
        @person_one.save
      
        @user2 = Factory.create :user
        @group2 = @user2.group(:name => "group two")

        @user.pending_requests.empty?.should be true
        @user.friends.empty?.should be true
        @user2.pending_requests.empty?.should be true
        @user2.friends.empty?.should be true

        @request = Request.instantiate(:to => @user.receive_url, :from => @person_one)
        @request_two = Request.instantiate(:to => @user2.receive_url, :from => @person_one)
        @request_three =  Request.instantiate(:to => @user2.receive_url, :from => @user.person)

        @req_xml = @request.to_diaspora_xml
        @req_two_xml = @request_two.to_diaspora_xml
        @req_three_xml = @request_three.to_diaspora_xml

        @request.destroy
        @request_two.destroy
        @request_three.destroy
      end

      it 'should befriend the user other user on the same pod' do

        @user2.receive @req_three_xml
        @user2.pending_requests.size.should be 1
        @user2.accept_friend_request @request_three.id, @group2.id
        @user2.friends.include?(@user.person).should be true  
        Person.all.count.should be 3
      end

      it 'should not delete the ignored user on the same pod' do

        @user2.receive @req_three_xml
        @user2.pending_requests.size.should be 1
        @user2.ignore_friend_request @request_three.id
        @user2.friends.include?(@user.person).should be false  
        Person.all.count.should be 3
      end
      
      it 'should both users should befriend the same person' do

        @user.receive @req_xml
        @user.pending_requests.size.should be 1
        @user.accept_friend_request @request.id, @group.id
        @user.friends.include?(@person_one).should be true  

        @user2.receive @req_two_xml
        @user2.pending_requests.size.should be 1
        @user2.accept_friend_request @request_two.id, @group2.id
        @user2.friends.include?(@person_one).should be true  
        Person.all.count.should be 3
      end

      it 'should keep the person around if one of the users rejects him' do

        @user.receive @req_xml
        @user.pending_requests.size.should be 1
        @user.accept_friend_request @request.id, @group.id
        @user.friends.include?(@person_one).should be true  

        @user2.receive @req_two_xml
        @user2.pending_requests.size.should be 1
        @user2.ignore_friend_request @request_two.id
        @user2.friends.include?(@person_one).should be false  
        Person.all.count.should be 3
      end

      it 'should not keep the person around if the users ignores them' do
        @user.receive @req_xml
        @user.pending_requests.size.should be 1
        @user.ignore_friend_request @user.pending_requests.first.id
        @user.friends.include?(@person_one).should be false  

        @user2.receive @req_two_xml
        @user2.pending_requests.size.should be 1
        @user2.ignore_friend_request @user2.pending_requests.first.id#@request_two.id
        @user2.friends.include?(@person_one).should be false 
        Person.all.count.should be 2
      end


    end

    describe 'a user accepting rejecting multiple people' do
      before do
        @person_one = Factory.create :person
        @person_two = Factory.create :person

        @user.pending_requests.empty?.should be true
        @user.friends.empty?.should be true

        @request = Request.instantiate(:to => @user.receive_url, :from => @person_one)
        @request_two = Request.instantiate(:to => @user.receive_url, :from => @person_two)
      end
      
      after do
        @user.receive_friend_request @request        

        @person_two.destroy
        @user.pending_requests.size.should be 1
        @user.friends.size.should be 0

        @user.receive_friend_request @request_two
        @user.pending_requests.size.should be 2
        @user.friends.size.should be 0

        @user.accept_friend_request @request.id, @group.id
        @user.pending_requests.size.should be 1
        @user.friends.size.should be 1
        @user.friends.include?(@person_one).should be true

        @user.ignore_friend_request @request_two.id
        @user.pending_requests.size.should be 0
        @user.friends.size.should be 1
        @user.friends.include?(@person_two).should be false

      end

    end

  describe 'unfriending' do
    before do
      @user2 = Factory.create :user
      @group2 = @user2.group(:name => "Gross people")
      
      request = @user.send_friend_request_to( @user2, @group)
      request.reverse_for @user2 
      @user2.activate_friend(@user.person, @group2)
      @user.receive request.to_diaspora_xml
    end

    it 'should unfriend the other user on the same seed' do
      @user.reload
      @user2.reload

      @user.friends.count.should == 1
      @user2.friends.count.should == 1
      
      @user.person.user_refs.should == 1

      @user2.person.user_refs.should == 1

      @user2.unfriend @user.person
      @user2.friends.count.should be 0

      @user.person.reload
      @user.person.user_refs.should == 0 

      @user.unfriended_by @user2.person

      @user2.person.reload
      @user2.person.user_refs.should == 0

      @group.reload
      @group2.reload
      @group.people.count.should == 0
      @group2.people.count.should == 0
    end
  end


  end
end
