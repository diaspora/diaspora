require File.dirname(__FILE__) + '/../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @group = @user.group(:name => 'heroes')
   end

  it 'should instantiate with a person and be valid' do
    user = User.instantiate(:email => "bob@bob.com",
                            :password => "password",
                            :password_confirmation => "password",
                            :person => 
                              {:profile => {
                                :first_name => "bob",
                                :last_name => "grimm"}})

    user.save.should be true
    user.person.should_not be nil
    user.person.profile.should_not be nil
  end

  describe 'friend requesting' do
    it "should assign a request to a group" do
      friend = Factory.create(:person)
      group = @user.group(:name => "Dudes")
      group.requests.size.should == 0

      @user.send_friend_request_to(friend.receive_url, group.id)

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

    it 'should not be able to friend request an existing friend' do
      friend = Factory.create(:person)
      
      @user.friends << friend
      @user.save


      @user.send_friend_request_to( friend.receive_url, @group.id ).should be nil
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
  end

  describe 'profiles' do
    it 'should be able to update their profile and send it to their friends' do 
      Factory.create(:person)
      
      updated_profile = {:profile => {:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com"}}
      
      message_queue.should_receive(:process)
      
      @user.person.update_profile(updated_profile).should == true
      @user.profile.image_url.should == "http://clown.com"
    end
  end

  describe 'receiving' do
    before do
      @user2 = Factory.create(:user)
      @user.friends << @user2.person
      @user2.friends << @user.person
      @user.person.user_refs += 1
      @user2.person.user_refs += 1
      @user.save
      @user2.save
    end

    it 'should be able to parse and store a status message from xml' do
      status_message = @user2.post :status_message, :message => 'store this!'
      person = @user2.person

      xml = status_message.to_diaspora_xml
      @user2.destroy
      status_message.destroy
      StatusMessage.all.size.should == 0
      @user.receive( xml )
      
      person.posts.first.message.should == 'store this!'
      StatusMessage.all.size.should == 1
    end
  end

  describe 'unfriending' do
    before do
      @user2 = Factory.create :user
      @group2 = @user2.group(:name => "Gross people")
      
      request = @user.send_friend_request_to( @user2.receive_url, @group.id)
      request.reverse @user2 
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
    end
  end
end
