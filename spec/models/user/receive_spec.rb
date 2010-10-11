#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => 'heroes') }

  let(:user2) { Factory(:user) }
  let(:aspect2) { user2.aspect(:name => 'losers') }

  let(:user3) { Factory(:user) }
  let(:aspect3) { user3.aspect(:name => 'heroes') }

  before do
    friend_users(user, aspect, user2, aspect2)
    friend_users(user, aspect, user3, aspect3)
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id
    person = user2.person

    xml = status_message.to_diaspora_xml
    user2.destroy
    status_message.destroy
    StatusMessage.all.size.should == 0
    user.receive( xml )

    Post.all(:person_id => person.id).first.message.should == 'store this!'
    StatusMessage.all.size.should == 1
  end

  it 'should not create new aspects on message receive' do
    num_aspects = user.aspects.size

    (0..5).each{ |n|
      status_message = user2.post :status_message, :message => "store this #{n}!", :to => aspect2.id
      xml = status_message.to_diaspora_xml
      user.receive( xml )
    }

    user.aspects.size.should == num_aspects
  end

  describe 'post refs' do
    it "should add a received post to the aspect and visible_posts array" do
      status_message = user.post :status_message, :message => "hi", :to =>aspect.id
      user.reload
      salmon = user.salmon(status_message).xml_for user2.person
      user2.receive_salmon salmon
      user2.reload
      user2.raw_visible_posts.include?(status_message).should be true
      aspect2.reload
      aspect2.posts.include?(status_message).should be_true
    end

    it 'should be removed on unfriending' do
      status_message = user2.post :status_message, :message => "hi", :to => aspect2.id
      user.receive status_message.to_diaspora_xml
      user.reload

      user.raw_visible_posts.count.should == 1

      user.unfriend(user2.person)

      user.reload
      user.raw_visible_posts.count.should == 0

      Post.count.should be 1
    end

    it 'should be remove a post if the noone links to it' do
      status_message = user2.post :status_message, :message => "hi", :to => aspect2.id
      user.receive status_message.to_diaspora_xml
      user.reload

      user.raw_visible_posts.count.should == 1

      person = user2.person
      user2.destroy
      user.unfriend(person)

      user.reload
      user.raw_visible_posts.count.should == 0

      Post.count.should be 0
    end

    it 'should keep track of user references for one person ' do
      status_message = user2.post :status_message, :message => "hi", :to => aspect2.id
      user.receive status_message.to_diaspora_xml
      user.reload

      user.raw_visible_posts.count.should == 1

      status_message.reload
      status_message.user_refs.should == 1

      user.unfriend(user2.person)
      status_message.reload

      user.reload
      user.raw_visible_posts.count.should == 0

      status_message.reload
      status_message.user_refs.should == 0

      Post.count.should be 1
    end

    it 'should not override userrefs on receive by another person' do
      user3.activate_friend(user2.person, aspect3)

      status_message = user2.post :status_message, :message => "hi", :to => aspect2.id
      user.receive status_message.to_diaspora_xml

      user3.receive status_message.to_diaspora_xml
      user.reload
      user3.reload

      user.raw_visible_posts.count.should == 1

      status_message.reload
      status_message.user_refs.should == 2

      user.unfriend(user2.person)
      status_message.reload

      user.reload
      user.raw_visible_posts.count.should == 0

      status_message.reload
      status_message.user_refs.should == 1

      Post.count.should be 1
    end
  end

  describe 'comments' do
    it 'should correctly marshal a stranger for the downstream user' do

      post = user.post :status_message, :message => "hello", :to => aspect.id

      user2.receive post.to_diaspora_xml
      user3.receive post.to_diaspora_xml

      comment = user2.comment('tada',:on => post)
      user.receive comment.to_diaspora_xml
      user.reload

      commenter_id = user2.person.id

      user2.person.delete
      user2.delete
      comment_id = comment.id

      comment.delete
      user3.receive comment.to_diaspora_xml
      user3.reload

      new_comment = Comment.find_by_id(comment_id)
      new_comment.should_not be_nil
      new_comment.person.should_not be_nil
      new_comment.person.profile.should_not be_nil

      user3.visible_person_by_id(commenter_id).should_not be_nil
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
