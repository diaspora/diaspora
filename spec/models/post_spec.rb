#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Post, :type => :model do
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
        expect(StatusMessage.owned_or_visible_by_user(@you)).to include(@post_from_contact)
      end

      it 'returns your posts' do
        expect(StatusMessage.owned_or_visible_by_user(@you)).to include(@your_post)
      end

      it 'returns public posts' do
        expect(StatusMessage.owned_or_visible_by_user(@you)).to include(@public_post)
      end

      it 'returns public post from your contact' do
        sm = FactoryGirl.create(:status_message, :author => eve.person, :public => true)

        expect(StatusMessage.owned_or_visible_by_user(@you)).to include(sm)
      end

      it 'does not return non contacts, non-public post' do
        expect(StatusMessage.owned_or_visible_by_user(@you)).not_to include(@post_from_stranger)
      end

      it 'should return the three visible posts' do
        expect(StatusMessage.owned_or_visible_by_user(@you).count(:all)).to eq(3)
      end
    end


    describe '.for_a_stream' do
      it 'calls #for_visible_shareable_sql' do
        time, order = double, double
        expect(Post).to receive(:for_visible_shareable_sql).with(time, order).and_return(Post)
        Post.for_a_stream(time, order)
      end

      it 'calls includes_for_a_stream' do
        expect(Post).to receive(:includes_for_a_stream)
        Post.for_a_stream(double, double)
      end

      it 'calls excluding_blocks if a user is present' do
        expect(Post).to receive(:excluding_blocks).with(alice).and_return(Post)
        Post.for_a_stream(double, double, alice)
      end
    end

    describe '.excluding_blocks' do
      before do
        @post = FactoryGirl.create(:status_message, :author => alice.person)
        @other_post = FactoryGirl.create(:status_message, :author => eve.person)

        bob.blocks.create(:person => alice.person)
      end

      it 'does not included blocked users posts' do
        expect(Post.excluding_blocks(bob)).not_to include(@post)
      end

      it 'includes not blocked users posts' do
        expect(Post.excluding_blocks(bob)).to include(@other_post)
      end

      it 'returns posts if you dont have any blocks' do
        expect(Post.excluding_blocks(alice).count).to eq(2)
      end
    end

    describe '.excluding_hidden_shareables' do
      before do
        @post = FactoryGirl.create(:status_message, :author => alice.person)
        @other_post = FactoryGirl.create(:status_message, :author => eve.person)
        bob.toggle_hidden_shareable(@post)
      end
      it 'excludes posts the user has hidden' do
        expect(Post.excluding_hidden_shareables(bob)).not_to include(@post)
      end
      it 'includes posts the user has not hidden' do
        expect(Post.excluding_hidden_shareables(bob)).to include(@other_post)
      end
    end

    describe '.excluding_hidden_content' do
      it 'calls excluding_blocks and excluding_hidden_shareables' do
        expect(Post).to receive(:excluding_blocks).and_return(Post)
        expect(Post).to receive(:excluding_hidden_shareables)
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
          expect(Post.for_a_stream(Time.now + 1, "created_at")).to eq(@posts)
          expect(Post.for_a_stream(Time.now + 1, "updated_at")).to eq(@posts.reverse)
        end
      end


      describe '.for_visible_shareable_sql' do
        it 'calls max_time' do
          time = Time.now + 1
          expect(Post).to receive(:by_max_time).with(time, 'created_at').and_return(Post)
          Post.for_visible_shareable_sql(time, 'created_at')
        end

        it 'defaults to 15 posts' do
          chain = double.as_null_object

          allow(Post).to receive(:by_max_time).and_return(chain)
          expect(chain).to receive(:limit).with(15).and_return(Post)
          Post.for_visible_shareable_sql(Time.now + 1, "created_at")
        end

      end

      # @posts[0] is the newest, @posts[5] is the oldest
      describe ".newer" do
        it 'returns the next post in the array' do
          expect(@posts[3].created_at).to be < @posts[2].created_at #post 2 is newer
          expect(Post.newer(@posts[3]).created_at.to_s).to eq(@posts[2].created_at.to_s) #its the newer post, not the newest
        end
      end

      describe ".older" do
        it 'returns the previous post in the array' do
          expect(Post.older(@posts[3]).created_at.to_s).to eq(@posts[4].created_at.to_s) #its the older post, not the oldest
          expect(@posts[3].created_at).to be > @posts[4].created_at #post 4 is older
        end
      end
    end
  end

  describe 'validations' do
    it 'validates uniqueness of guid and does not throw a db error' do
      message = FactoryGirl.create(:status_message)
      expect(FactoryGirl.build(:status_message, :guid => message.guid)).not_to be_valid
    end
  end

  describe 'post_type' do
    it 'returns the class constant' do
      status_message = FactoryGirl.create(:status_message)
      expect(status_message.post_type).to eq("StatusMessage")
    end
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = FactoryGirl.create(:status_message, :author => @user.person)
      @user.comment!(post, "hey")
      post.destroy
      expect(Post.where(:id => post.id).empty?).to eq(true)
      expect(Comment.where(:text => "hey").empty?).to eq(true)
    end
  end

  describe 'serialization' do
    it 'should serialize the handle and not the sender' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id
      xml = post.to_diaspora_xml

      expect(xml.include?("person_id")).to be false
      expect(xml.include?(@user.person.diaspora_handle)).to be true
    end
  end

  describe '.diaspora_initialize' do
    it 'takes provider_display_name' do
      sm = FactoryGirl.create(:status_message, :provider_display_name => 'mobile')
      expect(StatusMessage.diaspora_initialize(sm.attributes.merge(:author => bob.person)).provider_display_name).to eq('mobile')
    end
  end

  describe '#mutable?' do
    it 'should be false by default' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id
      expect(post.mutable?).to eq(false)
    end
  end

  describe '#subscribers' do
    it 'returns the people contained in the aspects the post appears in' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id

      expect(post.subscribers(@user)).to eq([])
    end

    it 'returns all a users contacts if the post is public' do
      post = @user.post :status_message, :text => "hello", :to => @aspect.id, :public => true

      expect(post.subscribers(@user).to_set).to eq(@user.contact_people.to_set)
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
      expect(@post.reload.updated_at.to_i).to eq(old_time.to_i)
      @post.update_likes_counter
      expect(@post.reload.updated_at.to_i).to eq(old_time.to_i)
    end
  end

  describe "#receive" do
    it 'returns false if the post does not verify' do
      @post = FactoryGirl.create(:status_message, :author => bob.person)
      expect(@post).to receive(:verify_persisted_shareable).and_return(false)
      expect(@post.receive(bob, eve.person)).to eq(false)
    end
  end

  describe "#receive_persisted" do
    before do
      @post = FactoryGirl.create(:status_message, :author => bob.person)
      @known_post = Post.new
      allow(bob).to receive(:contact_for).with(eve.person).and_return(double(:receive_shareable => true))
    end

    context "user knows about the post" do
      before do
        allow(bob).to receive(:find_visible_shareable_by_id).and_return(@known_post)
      end

      it 'updates attributes only if mutable' do
        allow(@known_post).to receive(:mutable?).and_return(true)
        expect(@known_post).to receive(:update_attributes)
        expect(@post.send(:receive_persisted, bob, eve.person, @known_post)).to eq(true)
      end

      it 'returns false if trying to update a non-mutable object' do
        allow(@known_post).to receive(:mutable?).and_return(false)
        expect(@known_post).not_to receive(:update_attributes)
        expect(@post.send(:receive_persisted, bob, eve.person, @known_post)).to eq(false)
      end
    end

    context "the user does not know about the post" do
      before do
        allow(bob).to receive(:find_visible_shareable_by_id).and_return(nil)
        allow(bob).to receive(:notify_if_mentioned).and_return(true)
      end

      it "receives the post from the contact of the author" do
        expect(@post.send(:receive_persisted, bob, eve.person, @known_post)).to eq(true)
      end

      it 'notifies the user if they are mentioned' do
        allow(bob).to receive(:contact_for).with(eve.person).and_return(double(:receive_shareable => true))
        expect(bob).to receive(:notify_if_mentioned).and_return(true)

        expect(@post.send(:receive_persisted, bob, eve.person, @known_post)).to eq(true)
      end
    end
  end

  describe '#receive_non_persisted' do
    context "the user does not know about the post" do
      before do
        @post = FactoryGirl.create(:status_message, :author => bob.person)
        allow(bob).to receive(:find_visible_shareable_by_id).and_return(nil)
        allow(bob).to receive(:notify_if_mentioned).and_return(true)
      end

      it "it receives the post from the contact of the author" do
        expect(bob).to receive(:contact_for).with(eve.person).and_return(double(:receive_shareable => true))
        expect(@post.send(:receive_non_persisted, bob, eve.person)).to eq(true)
      end

      it 'notifies the user if they are mentioned' do
        allow(bob).to receive(:contact_for).with(eve.person).and_return(double(:receive_shareable => true))
        expect(bob).to receive(:notify_if_mentioned).and_return(true)

        expect(@post.send(:receive_non_persisted, bob, eve.person)).to eq(true)
      end

      it 'returns false if the post does not save' do
        allow(@post).to receive(:save).and_return(false)
        expect(@post.send(:receive_non_persisted, bob, eve.person)).to eq(false)
      end
    end
  end

  describe '#reshares_count' do
    before :each do
      @post = @user.post :status_message, :text => "hello", :to => @aspect.id, :public => true
      expect(@post.reshares.size).to eq(0)
    end

    describe 'when post has not been reshared' do
      it 'returns zero' do
        expect(@post.reshares_count).to eq(0)
      end
    end

    describe 'when post has been reshared exactly 1 time' do
      before :each do
        expect(@post.reshares.size).to eq(0)
        @reshare = FactoryGirl.create(:reshare, :root => @post)
        @post.reload
        expect(@post.reshares.size).to eq(1)
      end

      it 'returns 1' do
        expect(@post.reshares_count).to eq(1)
      end
    end

    describe 'when post has been reshared more than once' do
      before :each do
        expect(@post.reshares.size).to eq(0)
        FactoryGirl.create(:reshare, :root => @post)
        FactoryGirl.create(:reshare, :root => @post)
        FactoryGirl.create(:reshare, :root => @post)
        @post.reload
        expect(@post.reshares.size).to eq(3)
      end

      it 'returns the number of reshares' do
        expect(@post.reshares_count).to eq(3)
      end
    end
  end

  describe "#after_create" do
    it "sets #interacted_at" do
      post = FactoryGirl.create(:status_message)
      expect(post.interacted_at).not_to be_blank
    end
  end

  describe "#find_by_guid_or_id_with_user" do
    it "succeeds with an id" do
      post = FactoryGirl.create :status_message, public: true
      expect(Post.find_by_guid_or_id_with_user(post.id)).to eq(post)
    end

    it "succeeds with an guid" do
      post = FactoryGirl.create :status_message, public: true
      expect(Post.find_by_guid_or_id_with_user(post.guid)).to eq(post)
    end

    it "looks up on the passed user object if it's non-nil" do
      post = FactoryGirl.create :status_message
      user = double
      expect(user).to receive(:find_visible_shareable_by_id).with(Post, post.id, key: :id).and_return(post)
      Post.find_by_guid_or_id_with_user post.id, user
    end

    it "raises ActiveRecord::RecordNotFound with a non-existing id and a user" do
      user = double(find_visible_shareable_by_id: nil)
      expect {
        Post.find_by_guid_or_id_with_user 123, user
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises Diaspora::NonPublic for a non-existing id without a user" do
      allow(Post).to receive_messages where: double(includes: double(first: nil))
      expect {
        Post.find_by_guid_or_id_with_user 123
      }.to raise_error Diaspora::NonPublic
    end

    it "raises Diaspora::NonPublic for a private post without a user" do
      post = FactoryGirl.create :status_message
      expect {
        Post.find_by_guid_or_id_with_user post.id
      }.to raise_error Diaspora::NonPublic
    end
  end
end
