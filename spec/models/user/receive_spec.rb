#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user) { Factory.create(:user) }
  let(:aspect) { user.aspects.create(:name => 'heroes') }

  let(:user2) { Factory.create(:user) }
  let(:aspect2) { user2.aspects.create(:name => 'losers') }

  let(:user3) { Factory.create(:user) }
  let(:aspect3) { user3.aspects.create(:name => 'heroes') }

  before do
    connect_users(user, aspect, user2, aspect2)
  end

  it 'streams only one message to the everyone aspect when a multi-aspected contacts posts' do
    contact = user.contact_for(user2.person)
    user.add_contact_to_aspect(contact, user.aspects.create(:name => "villains"))
    status = user2.build_post(:status_message, :message => "Users do things", :to => aspect2.id)
    xml = status.to_diaspora_xml
    Diaspora::WebSocket.should_receive(:queue_to_user).exactly(:once)
    user.receive xml, user2.person
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

    2.times do |n|
      status_message = user2.post :status_message, :message => "store this #{n}!", :to => aspect2.id
    end

    user.aspects.size.should == num_aspects
  end

  describe '#receive_salmon' do
   it 'should handle the case where the webfinger fails' do
     pending "Write this to test #receive_salmon"
    Webfinger.stub!(:fetch).and_return(nil)

    proc{
      user2.post :status_message, :message => "store this!", :to => aspect2.id
    }.should_not raise_error
   end
  end

  context 'update posts' do
    it 'does not update posts not marked as mutable' do
      status = user.post :status_message, :message => "store this!", :to => aspect.id
      status.message = 'foo'
      xml = status.to_diaspora_xml
      user2.receive(xml, user.person)
      status.reload.message.should == 'store this!'
    end

    it 'updates posts marked as mutable' do
      photo = user.post(:photo, :user_file => uploaded_photo, :caption => "Original", :to => aspect.id)
      photo.caption = 'foo'
      xml = photo.to_diaspora_xml
      user2.reload.receive(xml, user.person)
      photo.reload.caption.should match(/foo/)
    end
  end

  describe 'post refs' do
    before do
      @status_message = user2.post :status_message, :message => "hi", :to => aspect2.id
      user.reload
      aspect.reload
    end

    it "adds a received post to the aspect and visible_posts array" do
      user.raw_visible_posts.include?(@status_message).should be_true
      aspect.posts.include?(@status_message).should be_true
    end

    it 'removes posts upon disconnecting' do
      user.disconnect(user2.person)
      user.reload
      user.raw_visible_posts.should_not include @status_message
    end

    it 'deletes a post if the noone links to it' do
      person = Factory(:person)
      user.activate_contact(person, aspect)
      post = Factory.create(:status_message, :person => person)
      post.post_visibilities.should be_empty
      user.receive post.to_diaspora_xml, person
      aspect.post_visibilities.reset
      aspect.posts(true).should include(post)
      post.post_visibilities.reset
      post.post_visibilities.length.should == 1

      lambda {
        user.disconnected_by(person)
      }.should change(Post, :count).by(-1)
    end
    it 'deletes post_visibilities on disconnected by' do
      person = Factory(:person)
      user.activate_contact(person, aspect)
      post = Factory.create(:status_message, :person => person)
      post.post_visibilities.should be_empty
      user.receive post.to_diaspora_xml, person
      aspect.post_visibilities.reset
      aspect.posts(true).should include(post)
      post.post_visibilities.reset
      post.post_visibilities.length.should == 1

      lambda {
        user.disconnected_by(person)
      }.should change{post.post_visibilities(true).count}.by(-1)
    end
    it 'should keep track of user references for one person ' do
      @status_message.reload
      @status_message.user_refs.should == 2

      user.disconnect(user2.person)
      @status_message.reload
      @status_message.user_refs.should == 1
    end

    it 'should not override userrefs on receive by another person' do
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 2

      user3.activate_contact(user2.person, aspect3)
      user3.receive @status_message.to_diaspora_xml, user2.person

      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 3

      user.disconnect(user2.person)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 2
    end
  end

  describe 'comments' do
    before do
      connect_users(user, aspect, user3, aspect3)
      @post = user.post :status_message, :message => "hello", :to => aspect.id

      @comment = user3.comment('tada',:on => @post)
      @comment.post_creator_signature = @comment.sign_with_key(user.encryption_key)
      @xml = @comment.to_diaspora_xml
      @comment.delete
    end

    it 'should correctly attach the user already on the pod' do
      local_person = user3.person

      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = StatusMessage.find(@post.id)
      post_in_db.comments.should == []
      lambda{
        user2.receive(@xml, user.person)
      }.should change{StatusMessage.find(@post.id).comments.count}.by(1)
    end

    it 'should correctly marshal a stranger for the downstream user' do
      remote_person = user3.person.dup
      user3.person.delete
      user3.delete
      remote_person.id = nil

      #stubs async webfinger
      Person.should_receive(:by_account_identifier).twice.and_return{ |handle|
        if handle == user.person.diaspora_handle
          user.person.save
          user.person
        else
          remote_person.profile = Factory(:profile)
          remote_person.save!
          remote_person
        end
      }


      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = StatusMessage.find(@post.id)
      post_in_db.comments.should == []
      lambda{
        user2.receive(@xml, user.person)
      }.should change{StatusMessage.find(@post.id).comments.count}.by(1)
    end
  end

  describe 'salmon' do
    let(:post){user.post :status_message, :message => "hello", :to => aspect.id}
    let(:salmon){user.salmon( post )}

    it 'should receive a salmon for a post' do
      user2.receive_salmon( salmon.xml_for user2.person )
      user2.raw_visible_posts.include?(post).should be_true
    end
  end
end
