#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  before do
    @alices_aspect = alice.aspects.first
    @eves_aspect = eve.aspects.first
  end

  describe "#raw_visible_posts" do
    it "returns all the posts the user can see" do
      connect_users(eve, @eves_aspect, alice, @alices_aspect)
      self_post = alice.post(:status_message, :text => "hi", :to => @alices_aspect.id)
      visible_post = eve.post(:status_message, :text => "hello", :to => @eves_aspect.id)
      dogs = eve.aspects.create(:name => "dogs")
      invisible_post = eve.post(:status_message, :text => "foobar", :to => dogs.id)

      stream = alice.raw_visible_posts
      stream.should include(self_post)
      stream.should include(visible_post)
      stream.should_not include(invisible_post)
    end
  end

  context 'with two posts' do
    before do
      connect_users(eve, @eves_aspect, alice, @alices_aspect)
      aspect3 = alice.aspects.create(:name => "Snoozers")
      @status_message1 = eve.post :status_message, :text => "hi", :to => @eves_aspect.id
      @status_message2 = eve.post :status_message, :text => "hey", :public => true , :to => @eves_aspect.id
      @status_message3 = alice.post :status_message, :text => "hey", :public => true , :to => @alices_aspect.id
      @status_message4 = eve.post :status_message, :text => "blah", :public => true , :to => @eves_aspect.id
      @status_message5 = alice.post :status_message, :text => "secrets", :to => aspect3.id

      @pending_status_message = eve.post :status_message, :text => "hey", :public => true , :to => @eves_aspect.id, :pending => true
    end

    describe "#visible_posts" do
      it "queries by person id" do
        query = eve.raw_visible_posts.where(:author_id => eve.person.id)
        query.include?(@status_message1).should == true
        query.include?(@status_message2).should == true
        query.include?(@status_message3).should == false
        query.include?(@status_message4).should == true
        query.include?(@status_message5).should == false
      end

      it "selects public posts" do
        query = eve.raw_visible_posts.where(:public => true)
        query.include?(@status_message1).should == false
        query.include?(@status_message2).should == true
        query.include?(@status_message3).should == true
        query.include?(@status_message4).should == true
        query.include?(@status_message5).should == false
      end

      it "selects non public posts" do
        query = eve.raw_visible_posts.where(:public => false)
        query.include?(@status_message1).should == true
        query.include?(@status_message2).should == false
        query.include?(@status_message3).should == false
        query.include?(@status_message4).should == false
        query.include?(@status_message5).should == false
      end

      it "selects by message contents" do
        query = eve.raw_visible_posts.where(:text=> "hi")
        query.should == [@status_message1]
      end

      it "does not return pending posts" do
        @pending_status_message.pending.should be_true
        eve.raw_visible_posts.should_not include @pending_status_message
      end

      it '#find_visible_post_by_id' do
        eve.find_visible_post_by_id(@status_message1.id).should == @status_message1
        eve.find_visible_post_by_id(@status_message5.id).should == nil
      end
    end
  end

  context 'with two users' do
    describe '#people_in_aspects' do
      it 'returns people objects for a users contact in each aspect' do
        alice.people_in_aspects([@alices_aspect]).should == [bob.person]
      end

      it 'returns local/remote people objects for a users contact in each aspect' do
        local_user1 = Factory(:user)
        local_user2 = Factory(:user)
        remote_user = Factory(:user)

        asp1 = local_user1.aspects.create(:name => "lol")
        asp2 = local_user2.aspects.create(:name => "brb")
        asp3 = remote_user.aspects.create(:name => "ttyl")

        connect_users(alice, @alices_aspect, local_user1, asp1)
        connect_users(alice, @alices_aspect, local_user2, asp2)
        connect_users(alice, @alices_aspect, remote_user, asp3)

        local_person = remote_user.person
        local_person.owner_id = nil
        local_person.save
        local_person.reload

        alice.people_in_aspects([@alices_aspect]).count.should == 4
        alice.people_in_aspects([@alices_aspect], :type => 'remote').count.should == 1
        alice.people_in_aspects([@alices_aspect], :type => 'local').count.should == 3
      end

      it 'does not return people not connected to user on same pod' do
        3.times { Factory(:user) }
        alice.people_in_aspects([@alices_aspect]).count.should == 1
      end

      it "only returns non-pending contacts" do
        alice.send_contact_request_to(Factory(:user).person, @alices_aspect)
        @alices_aspect.reload
        alice.reload

        alice.people_in_aspects([@alices_aspect]).should == [bob.person]
      end

      it "returns an empty array when passed an aspect the user doesn't own" do
        other_user = Factory(:user_with_aspect)
        connect_users(eve, eve.aspects.first, other_user, other_user.aspects.first)
        alice.people_in_aspects([other_user.aspects.first]).should == []
      end
    end
  end

  context 'contact querying' do
    let(:person_one) { Factory.create :person }
    let(:person_two) { Factory.create :person }
    let(:person_three) { Factory.create :person }
    let(:aspect) { alice.aspects.create(:name => 'heroes') }
    describe '#contact_for_person_id' do
      it 'returns a contact' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact
        alice.contact_for_person_id(person_one.id).should be_true
      end

      it 'returns the correct contact' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact

        contact2 = Contact.create(:user => alice, :person => person_two, :aspects => [aspect])
        alice.contacts << contact2

        contact3 = Contact.create(:user => alice, :person => person_three, :aspects => [aspect])
        alice.contacts << contact3

        alice.contact_for_person_id(person_two.id).person.should == person_two
      end

      it 'returns nil for a non-contact' do
        alice.contact_for_person_id(person_one.id).should be_nil
      end

      it 'returns nil when someone else has contact with the target' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact
        eve.contact_for_person_id(person_one.id).should be_nil
      end
    end

    describe '#contact_for' do
      it 'takes a person_id and returns a contact' do
        alice.should_receive(:contact_for_person_id).with(person_one.id)
        alice.contact_for(person_one)
      end

      it 'returns nil if the input is nil' do
        alice.contact_for(nil).should be_nil
      end
    end
  end

  describe "#request_from" do
    let!(:user5) {Factory(:user)}

    it 'should not have a pending request before connecting' do
      request = alice.request_from(user5.person)
      request.should be_nil
    end

    it 'should have a pending request after sending a request' do
      alice.send_contact_request_to(user5.person, alice.aspects.first)
      request = user5.request_from(alice.person)
      request.should_not be_nil
    end
  end

  describe '#posts_from' do
    before do
      @user3 = Factory(:user)
      @aspect3 = @user3.aspects.create(:name => "bros")

      @public_message = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      @private_message = @user3.post(:status_message, :text => "hey there", :to => @aspect3.id)
    end

    it 'displays public posts for a non-contact' do
      alice.posts_from(@user3.person).should include @public_message
    end

    it 'does not display private posts for a non-contact' do
      alice.posts_from(@user3.person).should_not include @private_message
    end

    it 'displays private and public posts for a non-contact after connecting' do
      connect_users(alice, @alices_aspect, @user3, @aspect3)
      new_message = @user3.post(:status_message, :text=> "hey there", :to => @aspect3.id)

      alice.reload

      alice.posts_from(@user3.person).should include @public_message
      alice.posts_from(@user3.person).should include new_message
    end

    it 'displays recent posts first' do
      msg3 = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      msg4 = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      msg3.created_at = Time.now+10
      msg3.save!
      msg4.created_at = Time.now+14
      msg4.save!

      alice.posts_from(@user3.person).map{|p| p.id}.should == [msg4, msg3, @public_message].map{|p| p.id}
    end
  end
end
