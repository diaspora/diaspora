#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Post do
  before do
    @user = alice
    @aspect = @user.aspects.create(:name => "winners")
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
end
