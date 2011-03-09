#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  before do
    @user = alice
    @aspect = @user.aspects.first
    @user2 = eve
    @aspect2 = @user2.aspects.first

    @person_one = Factory.create :person
    @person_two = Factory.create :person
    @person_three = Factory.create :person
  end

  describe "#raw_visible_posts" do
    it "returns all the posts the user can see" do
      connect_users(@user2, @aspect2, @user, @aspect)
      self_post = @user.post(:status_message, :message => "hi", :to => @aspect.id)
      visible_post = @user2.post(:status_message, :message => "hello", :to => @aspect2.id)
      dogs = @user2.aspects.create(:name => "dogs")
      invisible_post = @user2.post(:status_message, :message => "foobar", :to => dogs.id)

      stream = @user.raw_visible_posts
      stream.should include(self_post)
      stream.should include(visible_post)
      stream.should_not include(invisible_post)
    end
  end

  context 'with two posts' do
    before do
      connect_users(@user2, @aspect2, @user, @aspect)
      aspect3 = @user.aspects.create(:name => "Snoozers")
      @status_message1 = @user2.post :status_message, :message => "hi", :to => @aspect2.id
      @status_message2 = @user2.post :status_message, :message => "hey", :public => true , :to => @aspect2.id
      @status_message3 = @user.post :status_message, :message => "hey", :public => true , :to => @aspect.id
      @status_message4 = @user2.post :status_message, :message => "blah", :public => true , :to => @aspect2.id
      @status_message5 = @user.post :status_message, :message => "secrets", :to => aspect3.id

      @pending_status_message = @user2.post :status_message, :message => "hey", :public => true , :to => @aspect2.id, :pending => true
    end

    describe "#visible_posts" do
      it "queries by person id" do
        query = @user2.visible_posts(:author_id => @user2.person.id)
        query.include?(@status_message1).should == true
        query.include?(@status_message2).should == true
        query.include?(@status_message3).should == false
        query.include?(@status_message4).should == true
        query.include?(@status_message5).should == false
      end

      it "selects public posts" do
        query = @user2.visible_posts(:public => true)
        query.include?(@status_message1).should == false
        query.include?(@status_message2).should == true
        query.include?(@status_message3).should == true
        query.include?(@status_message4).should == true
        query.include?(@status_message5).should == false
      end

      it "selects non public posts" do
        query = @user2.visible_posts(:public => false)
        query.include?(@status_message1).should == true
        query.include?(@status_message2).should == false
        query.include?(@status_message3).should == false
        query.include?(@status_message4).should == false
        query.include?(@status_message5).should == false
      end

      it "selects by message contents" do
        query = @user2.visible_posts(:message => "hi")
        query.should == [@status_message1]
      end

      it "does not return pending posts" do
        @pending_status_message.pending.should be_true
        @user2.visible_posts.should_not include @pending_status_message
      end

      it "queries by aspect" do
        query = @user.visible_posts(:by_members_of => @aspect)
        query.include?(@status_message1).should == true
        query.include?(@status_message2).should == true
        query.include?(@status_message3).should == true
        query.include?(@status_message4).should == true
        query.include?(@status_message5).should == false
        @user.visible_posts(:by_members_of => @user.aspects.create(:name => "aaaaah")).should be_empty
      end
      it '#find_visible_post_by_id' do
        @user2.find_visible_post_by_id(@status_message1.id).should == @status_message1
        @user2.find_visible_post_by_id(@status_message5.id).should == nil
      end
    end
  end

  context 'with two users' do
    let!(:user)          {Factory(:user)}
    let!(:first_aspect)  {user.aspects.create(:name => 'bruisers')}
    let!(:second_aspect) {user.aspects.create(:name => 'losers')}
    let!(:user4) { Factory.create(:user_with_aspect)}

    before do
      connect_users(user, first_aspect, user4, user4.aspects.first)
      connect_users(user, second_aspect, @user2, @user2.aspects.first)
    end

    describe '#people_in_aspects' do
      it 'returns people objects for a users contact in each aspect' do
        people = @user.people_in_aspects([first_aspect])
        people.should == [user4.person]
        people = @user.people_in_aspects([second_aspect])
        people.should == [@user2.person]
      end

      it 'returns local/remote people objects for a users contact in each aspect' do
        local_user1 = Factory(:user)
        local_user2 = Factory(:user)
        remote_user = Factory(:user)

        asp1 = local_user1.aspects.create(:name => "lol")
        asp2 = local_user2.aspects.create(:name => "brb")
        asp3 = remote_user.aspects.create(:name => "ttyl")

        connect_users(user, first_aspect, local_user1, asp1)
        connect_users(user, first_aspect, local_user2, asp2)
        connect_users(user, first_aspect, remote_user, asp3)

        local_person = remote_user.person
        local_person.owner_id = nil
        local_person.save
        local_person.reload

        @user.people_in_aspects([first_aspect]).count.should == 4
        @user.people_in_aspects([first_aspect], :type => 'remote').count.should == 1
        q = @user.people_in_aspects([first_aspect], :type => 'local')
        q.count.should == 3
      end

      it 'does not return people not connected to user on same pod' do
        local_user1 = Factory(:user)
        local_user2 = Factory(:user)
        local_user3 = Factory(:user)

        @user.people_in_aspects([first_aspect]).count.should == 1
      end
    end
  end

  context 'contact querying' do
    let(:person_one) { Factory.create :person }
    let(:person_two) { Factory.create :person }
    let(:person_three) { Factory.create :person }
    let(:aspect) { @user.aspects.create(:name => 'heroes') }
    describe '#contact_for_person_id' do
      it 'returns a contact' do
        contact = Contact.create(:user => @user, :person => person_one, :aspects => [aspect])
        @user.contacts << contact
        @user.contact_for_person_id(person_one.id).should be_true
      end

      it 'returns the correct contact' do
        contact = Contact.create(:user => @user, :person => person_one, :aspects => [aspect])
        @user.contacts << contact

        contact2 = Contact.create(:user => @user, :person => person_two, :aspects => [aspect])
        @user.contacts << contact2

        contact3 = Contact.create(:user => @user, :person => person_three, :aspects => [aspect])
        @user.contacts << contact3

        @user.contact_for_person_id(person_two.id).person.should == person_two
      end

      it 'returns nil for a non-contact' do
        @user.contact_for_person_id(person_one.id).should be_nil
      end

      it 'returns nil when someone else has contact with the target' do
        contact = Contact.create(:user => @user, :person => person_one, :aspects => [aspect])
        @user.contacts << contact
        @user2.contact_for_person_id(person_one.id).should be_nil
      end
    end

    describe '#contact_for' do
      it 'takes a person_id and returns a contact' do
        @user.should_receive(:contact_for_person_id).with(person_one.id)
        @user.contact_for(person_one)
      end

      it 'returns nil if the input is nil' do
        @user.contact_for(nil).should be_nil
      end
    end
  end

  describe "#request_from" do
    let!(:user5) {Factory(:user)}

    it 'should not have a pending request before connecting' do
      request = @user.request_from(user5.person)
      request.should be_nil
    end

    it 'should have a pending request after sending a request' do
      @user.send_contact_request_to(user5.person, @user.aspects.first)
      request = user5.request_from(@user.person)
      request.should_not be_nil
    end
  end

  describe '#posts_from' do
    before do
      @user3 = Factory(:user)
      @aspect3 = @user3.aspects.create(:name => "bros")

      @public_message = @user3.post(:status_message, :message => "hey there", :to => 'all', :public => true)
      @private_message = @user3.post(:status_message, :message => "hey there", :to => @aspect3.id)
    end

    it 'displays public posts for a non-contact' do
      @user.posts_from(@user3.person).should include @public_message
    end

    it 'does not display private posts for a non-contact' do
      @user.posts_from(@user3.person).should_not include @private_message
    end

    it 'displays private and public posts for a non-contact after connecting' do
      connect_users(@user, @aspect, @user3, @aspect3)
      new_message = @user3.post(:status_message, :message => "hey there", :to => @aspect3.id)

      @user.reload

      @user.posts_from(@user3.person).should include @public_message
      @user.posts_from(@user3.person).should include new_message
    end

    it 'displays recent posts first' do
      msg3 = @user3.post(:status_message, :message => "hey there", :to => 'all', :public => true)
      msg4 = @user3.post(:status_message, :message => "hey there", :to => 'all', :public => true)
      msg3.updated_at = Time.now+10
      msg3.save!
      msg4.updated_at = Time.now+14
      msg4.save!

      @user.posts_from(@user3.person).map{|p| p.id}.should == [msg4, msg3, @public_message].map{|p| p.id}
    end
  end
end
