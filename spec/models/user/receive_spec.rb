#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'heroes') }

  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => 'losers') }

  let(:user3) { make_user }
  let(:aspect3) { user3.aspects.create(:name => 'heroes') }

  before do
    friend_users(user, aspect, user2, aspect2)
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id

    xml = status_message.to_diaspora_xml
    user2.delete
    status_message.destroy

    lambda {user.receive xml , user2.person}.should change(Post,:count).by(1)
  end

  it 'should not create new aspects on message receive' do
    num_aspects = user.aspects.size

    (0..5).each{ |n|
      status_message = user2.post :status_message, :message => "store this #{n}!", :to => aspect2.id
      xml = status_message.to_diaspora_xml
      user.receive xml, user2.person
    }

    user.aspects.size.should == num_aspects
  end

  context 'update posts' do
    let(:status) {user.post(:status_message, :message => "Original", :to => aspect.id)}
    let(:album)  {user.post(:album, :name => "Original", :to => aspect.id)}

    it 'does not update posts not marked as mutable' do
      user2.receive_salmon(user.salmon(status).xml_for(user2.person))
      status.message = 'foo'
      xml = user.salmon(status).xml_for(user2.person)

      status.reload.message.should == 'Original'

      user2.receive_salmon(xml)

      status.reload.message.should == 'Original'
    end

    it 'updates posts marked as mutable' do
      user2.receive_salmon(user.salmon(album).xml_for(user2.person))
      album.name = 'foo'
      xml = user.salmon(album).xml_for(user2.person)

      album.reload.name.should == 'Original'

      user2.receive_salmon(xml)

      album.reload.name.should == 'foo'
    end

  end

  describe 'post refs' do
    before do
      @status_message = user2.post :status_message, :message => "hi", :to =>aspect2.id
      user.receive @status_message.to_diaspora_xml, user2.person
      user.reload
    end

    it "should add a received post to the aspect and visible_posts array" do
      user.raw_visible_posts.include?(@status_message).should be true
      aspect.reload
      aspect.posts.include?(@status_message).should be_true
    end

    it 'should be removed on unfriending' do
      user.unfriend(user2.person)
      user.reload
      user.raw_visible_posts.count.should == 0
    end

    it 'should be remove a post if the noone links to it' do
      person = user2.person
      user2.delete

      lambda {user.unfriend(person)}.should change(Post, :count).by(-1)
      user.reload
      user.raw_visible_posts.count.should == 0
    end

    it 'should keep track of user references for one person ' do
      @status_message.reload
      @status_message.user_refs.should == 1

      user.unfriend(user2.person)
      @status_message.reload
      @status_message.user_refs.should == 0
    end

    it 'should not override userrefs on receive by another person' do
      user3.activate_friend(user2.person, aspect3)
      user3.receive @status_message.to_diaspora_xml, user2.person

      @status_message.reload
      @status_message.user_refs.should == 2

      user.unfriend(user2.person)
      @status_message.reload
      @status_message.user_refs.should == 1
    end
  end

  describe 'comments' do
    before do
      friend_users(user, aspect, user3, aspect3)
      @post = user.post :status_message, :message => "hello", :to => aspect.id

      user2.receive @post.to_diaspora_xml, user.person
      user3.receive @post.to_diaspora_xml, user.person

      @comment = user3.comment('tada',:on => @post)
      @comment.post_creator_signature = @comment.sign_with_key(user.encryption_key)
      @xml = user.salmon(@comment).xml_for(user2.person)
      @comment.delete
    end

    it 'should correctly attach the user already on the pod' do
      local_person = user3.person

      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = user2.raw_visible_posts.first
      post_in_db.comments.should == []
      user2.receive_salmon(@xml)
      post_in_db.reload
      
      post_in_db.comments.include?(@comment).should be true
      post_in_db.comments.first.person.should == local_person
    end
    
    it 'should correctly marshal a stranger for the downstream user' do
      remote_person = user3.person
      remote_person.delete
      user3.delete

      #stubs async webfinger
      Person.should_receive(:by_account_identifier).twice.and_return{ |handle| if handle == user.person.diaspora_handle; user.person.save
        user.person; else; remote_person.save; remote_person; end }

      
      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = user2.raw_visible_posts.first
      post_in_db.comments.should == []
      user2.receive_salmon(@xml)
      post_in_db.reload
      
      post_in_db.comments.include?(@comment).should be true
      post_in_db.comments.first.person.should == remote_person
    end
  end

  describe 'salmon' do
    let(:post){user.post :status_message, :message => "hello", :to => aspect.id}
    let(:salmon){user.salmon( post )}

    it 'should receive a salmon for a post' do
      user2.receive_salmon( salmon.xml_for user2.person )
      user2.visible_post_ids.include?(post.id).should be true
    end
  end
end
