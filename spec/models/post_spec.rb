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
    describe '.for_a_stream' do
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

      it 'returns the posts ordered and limited by unix time' do
        Post.for_a_stream(Time.now + 1, "created_at").should == @posts
        Post.for_a_stream(Time.now + 1, "updated_at").should == @posts.reverse
      end

      it 'includes everything in .includes_for_a_stream' do
        Post.should_receive(:includes_for_a_stream)
        Post.for_a_stream(Time.now + 1, "created_at")
      end
      it 'is limited to 15 posts' do
        Post.stub(:by_max_time).and_return(Post)
        Post.stub(:includes_for_a_stream).and_return(Post)
        Post.should_receive(:limit)
        Post.for_a_stream(Time.now + 1, "created_at")
      end
    end

    describe 'includes for a stream' do
      it 'inclues author profile and mentions' 
      it 'should include photos and root of reshares(but does not)'
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

  describe '#last_three_comments' do
    it 'returns the last three comments of a post' do
      post = bob.post :status_message, :text => "hello", :to => 'all'
      created_at = Time.now - 100
      comments = [alice, eve, bob, alice].map do |u|
        created_at = created_at + 10
        u.comment("hey", :post => post, :created_at => created_at)
      end
      post.last_three_comments.map{|c| c.id}.should == comments[1,3].map{|c| c.id}
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
      @post.should_receive(:verify_persisted_post).and_return(false)
      @post.receive(bob, eve.person).should == false
    end
  end

  describe "#receive_persisted" do
    before do
      @post = Factory.build(:status_message, :author => bob.person)
      @known_post = Post.new
      bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_post => true))
    end

    context "user knows about the post" do
      before do
        bob.stub(:find_visible_post_by_id).and_return(@known_post)
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
        bob.stub(:find_visible_post_by_id).and_return(nil)
        bob.stub(:notify_if_mentioned).and_return(true)
      end

      it "receives the post from the contact of the author" do
        @post.send(:receive_persisted, bob, eve.person, @known_post).should == true
      end
      
      it 'notifies the user if they are mentioned' do
        bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_post => true))
        bob.should_receive(:notify_if_mentioned).and_return(true)

        @post.send(:receive_persisted, bob, eve.person, @known_post).should == true
      end
    end
  end

  describe '#receive_non_persisted' do
    context "the user does not know about the post" do
      before do
        @post = Factory.build(:status_message, :author => bob.person)
        bob.stub(:find_visible_post_by_id).and_return(nil)
        bob.stub(:notify_if_mentioned).and_return(true)
      end

      it "it receives the post from the contact of the author" do
        bob.should_receive(:contact_for).with(eve.person).and_return(stub(:receive_post => true))
        @post.send(:receive_non_persisted, bob, eve.person).should == true
      end
      
      it 'notifies the user if they are mentioned' do
        bob.stub(:contact_for).with(eve.person).and_return(stub(:receive_post => true))
        bob.should_receive(:notify_if_mentioned).and_return(true)

        @post.send(:receive_non_persisted, bob, eve.person).should == true
      end

      it 'returns false if the post does not save' do
        @post.stub(:save).and_return(false)
        @post.send(:receive_non_persisted, bob, eve.person).should == false
      end
    end
  end
end
