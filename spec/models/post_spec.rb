#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Post do
  before do
    @user = alice
    @aspect = @user.aspects.create(:name => "winners")
  end

  describe 'scopes' do
    describe '.owned_or_visible_by_user' do
      before do
        @you = bob
        @public_post = FactoryGirl.create(:status_message, :public => true)
        @your_post = FactoryGirl.create(:status_message, :author => @you.person)
        @post_from_contact = eve.post(:status_message, :text => 'wooo', :to => eve.aspects.where(:name => 'generic').first)
        @post_from_stranger = FactoryGirl.create(:status_message, :public => false)
      end

      it 'returns post from your contacts' do
        StatusMessage.owned_or_visible_by_user(@you).should include(@post_from_contact)
      end

      it 'returns your posts' do
        StatusMessage.owned_or_visible_by_user(@you).should include(@your_post)
      end

      it 'returns public posts' do
        StatusMessage.owned_or_visible_by_user(@you).should include(@public_post)
      end

      it 'returns public post from your contact' do
        sm = FactoryGirl.create(:status_message, :author => eve.person, :public => true)

        StatusMessage.owned_or_visible_by_user(@you).should include(sm)
      end

      it 'does not return non contacts, non-public post' do
        StatusMessage.owned_or_visible_by_user(@you).should_not include(@post_from_stranger)
      end

      it 'should return the three visible posts' do
        StatusMessage.owned_or_visible_by_user(@you).count.should == 3
      end
    end


    describe '.for_a_stream' do
      it 'calls #for_visible_shareable_sql' do
        time, order = stub, stub
        Post.should_receive(:for_visible_shareable_sql).with(time, order).and_return(Post)
        Post.for_a_stream(time, order)
      end

      it 'calls includes_for_a_stream' do
        Post.should_receive(:includes_for_a_stream)
        Post.for_a_stream(stub, stub)
      end

      it 'calls excluding_blocks if a user is present' do
        Post.should_receive(:excluding_blocks).with(alice).and_return(Post)
        Post.for_a_stream(stub, stub, alice)
      end
    end

    describe '.excluding_blocks' do
      before do
        @post = FactoryGirl.create(:status_message, :author => alice.person)
        @other_post = FactoryGirl.create(:status_message, :author => eve.person)

        bob.blocks.create(:person => alice.person)
      end

      it 'does not included blocked users posts' do
        Post.excluding_blocks(bob).should_not include(@post)
      end

      it 'includes not blocked users posts' do
        Post.excluding_blocks(bob).should include(@other_post)
      end

      it 'returns posts if you dont have any blocks' do
        Post.excluding_blocks(alice).count.should == 2
      end
    end

    describe '.excluding_hidden_shareables' do
      before do
        @post = FactoryGirl.create(:status_message, :author => alice.person)
        @other_post = FactoryGirl.create(:status_message, :author => eve.person)
        bob.toggle_hidden_shareable(@post)
      end
      it 'excludes posts the user has hidden' do
        Post.excluding_hidden_shareables(bob).should_not include(@post)
      end
      it 'includes posts the user has not hidden' do
        Post.excluding_hidden_shareables(bob).should include(@other_post)
      end
    end

    describe '.excluding_hidden_content' do
      it 'calls excluding_blocks and excluding_hidden_shareables' do
        Post.should_receive(:excluding_blocks).and_return(Post)
        Post.should_receive(:excluding_hidden_shareables)
        Post.excluding_hidden_content(bob)
      end
    end

    context 'having some posts' do
      before do
        time_interval = 1000
        time_past = 1000000
        @posts = (1..5).map do |n|
          aspect_to_post = alice.aspects.where(:name => "generic").first
          post = alice.post :status_message, :text => "#{alice.username} - #{n}", :to => aspect_to_post.id
          post.created_at = (post.created_at-time_past) - time_interval
          post.updated_at = (post.updated_at-time_past) + time_interval
          post.save
          time_interval += 1000
          post
        end
      end

      describe '.by_max_time' do

        it 'returns the posts ordered and limited by unix time' do
          Post.for_a_stream(Time.now + 1, "created_at").should == @posts
          Post.for_a_stream(Time.now + 1, "updated_at").should == @posts.reverse
        end
      end


      describe '.for_visible_shareable_sql' do
        it 'calls max_time' do
          time = Time.now + 1
          Post.should_receive(:by_max_time).with(time, 'created_at').and_return(Post)
          Post.for_visible_shareable_sql(time, 'created_at')
        end

        it 'defaults to 15 posts' do
          chain = stub.as_null_object

          Post.stub(:by_max_time).and_return(chain)
          chain.should_receive(:limit).with(15).and_return(Post)
          Post.for_visible_shareable_sql(Time.now + 1, "created_at")
        end

      end

      # @posts[0] is the newest, @posts[5] is the oldest
      describe ".newer" do
        it 'returns the next post in the array' do
          @posts[3].created_at.should < @posts[2].created_at #post 2 is newer
          Post.newer(@posts[3]).created_at.to_s.should == @posts[2].created_at.to_s #its the newer post, not the newest
        end
      end

      describe ".older" do
        it 'returns the previous post in the array' do
          Post.older(@posts[3]).created_at.to_s.should == @posts[4].created_at.to_s #its the older post, not the oldest
          @posts[3].created_at.should > @posts[4].created_at #post 4 is older
        end
      end
    end
  end

  describe 'validations' do
    it 'validates uniqueness of guid and does not throw a db error' do
      message = FactoryGirl.create(:status_message)
      FactoryGirl.build(:status_message, :guid => message.guid).should_not be_valid
    end
  end

  describe 'post_type' do
    it 'returns the class constant' do
      status_message = FactoryGirl.create(:status_message)
      status_message.post_type.should == "StatusMessage"
    end
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = FactoryGirl.create(:status_message, :author => @user.person)
      @user.comment!(post, "hey")
      post.destroy
      Post.where(:id => post.id).empty?.should == true
      Comment.where(:text => "hey").empty?.should == true
    end
  end

  describe 'serialization' do
    it 'should serialize the handle and not the sender' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id
      xml = post.to_diaspora_xml

      xml.include?("person_id").should be false
      xml.include?(@user.person.diaspora_handle).should be true
    end
  end

  describe '.diaspora_initialize' do
    it 'takes provider_display_name' do
      sm = FactoryGirl.create(:status_message, :provider_display_name => 'mobile')
      StatusMessage.diaspora_initialize(sm.attributes.merge(:author => bob.person)).provider_display_name.should == 'mobile'
    end
  end

  describe '#mutable?' do
    it 'should be false by default' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id
      post.mutable?.should == false
    end
  end

  describe '#subscribers' do
    it 'returns the people contained in the aspects the post appears in' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id

      post.subscribers(@user).should == []
    end

    it 'returns all a users contacts if the post is public' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id, :public => true

      post.subscribers(@user).to_set.should == @user.contact_people.to_set
    end
  end

  describe 'Likeable#update_likes_counter' do
    before do
      @post = bob.post :status_message, :text => "hello", :to => 'all'
      bob.like!(@post)
    end
    it 'does not update updated_at' do
      old_time = Time.zone.now - 10000
      Post.where(:id => @post.id).update_all(:updated_at => old_time)
      @post.reload.updated_at.to_i.should == old_time.to_i
      @post.update_likes_counter
      @post.reload.updated_at.to_i.should == old_time.to_i
    end
  end

  describe "#receive" do
    it 'returns false if the post does not verify' do
      @post = FactoryGirl.create(:status_message, :author => bob.person)
      @post.should_receive(:verify_persisted_shareable).and_return(false)
      @post.receive(bob, eve.person).should == false
    end
  end

  describe "#receive_persisted" do
    before do
      @post = FactoryGirl.create(:status_message, :author => bob.person)
      @known_post = Post.new
      bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_shareable => true))
    end

    context "user knows about the post" do
      before do
        bob.stub(:find_visible_shareable_by_id).and_return(@known_post)
      end

      it 'updates attributes only if mutable' do
        @known_post.stub(:mutable?).and_return(true)
        @known_post.should_receive(:update_attributes)
        @post.send(:receive_persisted, bob, eve.person, @known_post).should == true
      end

      it 'returns false if trying to update a non-mutable object' do
        @known_post.stub(:mutable?).and_return(false)
        @known_post.should_not_receive(:update_attributes)
        @post.send(:receive_persisted, bob, eve.person, @known_post).should == false
      end
    end

    context "the user does not know about the post" do
      before do
        bob.stub(:find_visible_shareable_by_id).and_return(nil)
        bob.stub(:notify_if_mentioned).and_return(true)
      end

      it "receives the post from the contact of the author" do
        @post.send(:receive_persisted, bob, eve.person, @known_post).should == true
      end

      it 'notifies the user if they are mentioned' do
        bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_shareable => true))
        bob.should_receive(:notify_if_mentioned).and_return(true)

        @post.send(:receive_persisted, bob, eve.person, @known_post).should == true
      end
    end
  end

  describe '#receive_non_persisted' do
    context "the user does not know about the post" do
      before do
        @post = FactoryGirl.create(:status_message, :author => bob.person)
        bob.stub(:find_visible_shareable_by_id).and_return(nil)
        bob.stub(:notify_if_mentioned).and_return(true)
      end

      it "it receives the post from the contact of the author" do
        bob.should_receive(:contact_for).with(eve.person).and_return(stub(:receive_shareable => true))
        @post.send(:receive_non_persisted, bob, eve.person).should == true
      end

      it 'notifies the user if they are mentioned' do
        bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_shareable => true))
        bob.should_receive(:notify_if_mentioned).and_return(true)

        @post.send(:receive_non_persisted, bob, eve.person).should == true
      end

      it 'returns false if the post does not save' do
        @post.stub(:save).and_return(false)
        @post.send(:receive_non_persisted, bob, eve.person).should == false
      end
    end
  end

  describe '#reshares_count' do
    before :each do
      @post = @user.post :status_message, :text => "hello", :to => @aspect.id, :public => true
      @post.reshares.size.should == 0
    end

    describe 'when post has not been reshared' do
      it 'returns zero' do
        @post.reshares_count.should == 0
      end
    end

    describe 'when post has been reshared exactly 1 time' do
      before :each do
        @post.reshares.size.should == 0
        @reshare = FactoryGirl.create(:reshare, :root => @post)
        @post.reload
        @post.reshares.size.should == 1
      end

      it 'returns 1' do
        @post.reshares_count.should == 1
      end
    end

    describe 'when post has been reshared more than once' do
      before :each do
        @post.reshares.size.should == 0
        FactoryGirl.create(:reshare, :root => @post)
        FactoryGirl.create(:reshare, :root => @post)
        FactoryGirl.create(:reshare, :root => @post)
        @post.reload
        @post.reshares.size.should == 3
      end

      it 'returns the number of reshares' do
        @post.reshares_count.should == 3
      end
    end
  end

  describe "#after_create" do
    it "sets #interacted_at" do
      post = FactoryGirl.create(:status_message)
      post.interacted_at.should_not be_blank
    end
  end


end
