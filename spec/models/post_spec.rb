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
        @public_post = Factory(:status_message, :public => true)
        @your_post = Factory(:status_message, :author => @you.person)
        @post_from_contact = eve.post(:status_message, :text => 'wooo', :to => eve.aspects.where(:name => 'generic').first)
        @post_from_stranger = Factory(:status_message, :public => false)
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
        sm = Factory(:status_message, :author => eve.person, :public => true)

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
        user = stub
        Post.should_receive(:excluding_blocks).with(user)
        Post.for_a_stream(stub, stub, user)
      end
    end

    describe '.excluding_blocks' do
      before do
        @post = Factory(:status_message, :author => alice.person)
        @other_post = Factory(:status_message, :author => eve.person)

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

    context 'having some posts' do
      before do
        time_interval = 1000
        time_past = 1000000
        @posts = (1..3).map do |n|
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
        it 'respects time and order' do
        end

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
    end
  end


  describe 'validations' do
    it 'validates uniqueness of guid and does not throw a db error' do
      message = Factory(:status_message)
      Factory.build(:status_message, :guid => message.guid).should_not be_valid
    end
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = Factory.create(:status_message, :author => @user.person)
      @user.comment "hey", :post => post
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
      sm = Factory.build(:status_message, :provider_display_name => 'mobile')
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

  describe '#comments' do
    it 'returns the comments of a post in created_at order' do
      post = bob.post :status_message, :text => "hello", :to => 'all'
      created_at = Time.now - 100

      # Posts are created out of time order.
      # i.e. id order is not created_at order
      alice.comment 'comment a', :post => post, :created_at => created_at + 10
      eve.comment   'comment d', :post => post, :created_at => created_at + 50
      bob.comment   'comment b', :post => post, :created_at => created_at + 30
      alice.comment 'comment e', :post => post, :created_at => created_at + 90
      eve.comment   'comment c', :post => post, :created_at => created_at + 40

      post.comments.map(&:text).should == [
        'comment a',
        'comment b',
        'comment c',
        'comment d',
        'comment e',
      ]
      post.comments.map(&:author).should == [
        alice.person,
        bob.person,
        eve.person,
        eve.person,
        alice.person,
      ]
    end
  end

  describe 'Likeable#update_likes_counter' do
    before do
      @post = bob.post :status_message, :text => "hello", :to => 'all'
      bob.like(1, :target => @post)
    end
    it 'does not update updated_at' do
      old_time = Time.zone.now - 10000
      Post.where(:id => @post.id).update_all(:updated_at => old_time)
      @post.reload.updated_at.to_i.should == old_time.to_i
      @post.update_likes_counter
      @post.reload.updated_at.to_i.should == old_time.to_i
    end
  end

  describe "triggers_caching?" do
    it 'returns true' do
      Post.new.triggers_caching?.should be_true
    end
  end

  describe "after_create" do
    it "calls cache_for_author only on create" do
      post = Factory.build(:status_message, :author => bob.person)
      post.should_receive(:cache_for_author).once
      post.save
      post.save
    end
  end

  describe '#cache_for_author' do
    before do
      @post = Factory.build(:status_message, :author => bob.person)
      @post.stub(:should_cache_for_author?).and_return(true)
    end

    it 'caches with valid conditions' do
      cache = mock.as_null_object
      RedisCache.should_receive(:new).and_return(cache)
      cache.should_receive(:add)
      @post.cache_for_author
    end

    it 'does nothing if should not cache' do
      @post.stub(:should_cache_for_author?).and_return(false)
      RedisCache.should_not_receive(:new)
      @post.cache_for_author
    end
  end

  describe "#should_cache_for_author?" do
    before do
      @post = Factory.build(:status_message, :author => bob.person)
      RedisCache.stub(:configured?).and_return(true)
      RedisCache.stub(:acceptable_types).and_return(['StatusMessage'])
      @post.stub(:triggers_caching?).and_return(true)
    end

    it 'returns true under valid conditions' do
      @post.should_cache_for_author?.should be_true
    end

    it 'does not cache if the author is not a local user' do
      @post.author = Factory(:person)
      @post.should_cache_for_author?.should be_false
    end

    it 'does not cache if the cache is not configured' do
      RedisCache.stub(:configured?).and_return(false)
      @post.should_cache_for_author?.should be_false
    end

    it 'does not cache if the object does not triggers caching' do
      @post.stub(:triggers_caching?).and_return(false)
      @post.should_cache_for_author?.should be_false
    end

    it 'does not cache if the object is not of an acceptable cache type' do
      @post.stub(:type).and_return("Photo")
      @post.should_cache_for_author?.should be_false
    end
  end

  describe "#receive" do
    it 'returns false if the post does not verify' do
      @post = Factory(:status_message, :author => bob.person)
      @post.should_receive(:verify_persisted_shareable).and_return(false)
      @post.receive(bob, eve.person).should == false
    end
  end

  describe "#receive_persisted" do
    before do
      @post = Factory.build(:status_message, :author => bob.person)
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
        @post = Factory.build(:status_message, :author => bob.person)
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
        @reshare = Factory.create(:reshare, :root => @post)
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
        Factory.create(:reshare, :root => @post)
        Factory.create(:reshare, :root => @post)
        Factory.create(:reshare, :root => @post)
        @post.reload
        @post.reshares.size.should == 3
      end

      it 'returns the number of reshares' do
        @post.reshares_count.should == 3
      end
    end
  end
end
