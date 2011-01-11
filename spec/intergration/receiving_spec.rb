#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'a user receives a post' do

  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'heroes') }

  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => 'losers') }

  let(:user3) { make_user }
  let(:aspect3) { user3.aspects.create(:name => 'heroes') }

  def zord(user, person, xml)
    zord = Postzord::Receiver.new(user, :person => person)
    zord.parse_and_receive(xml)
  end

  before do
    connect_users(user, aspect, user2, aspect2)
  end



  it 'should stream only one message to the everyone aspect when a multi-aspected contacts posts' do
    contact = user.contact_for(user2.person)
    user.add_contact_to_aspect(contact, user.aspects.create(:name => "villains"))
    status = user2.post(:status_message, :message => "Users do things", :to => aspect2.id)
    #xml = status.to_diaspora_xml
    Diaspora::WebSocket.should_receive(:queue_to_user).exactly(:once)
    zord = Postzord::Receiver.new(user, :object => status, :person => user2.person)
    zord.receive_object
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = user2.post :status_message, :message => 'store this!', :to => aspect2.id

    xml = status_message.to_diaspora_xml
    user2.delete
    status_message.destroy

    lambda {
      zord(user, user2.person, xml)
    }.should change(Post,:count).by(1)
  end

  it 'should not create new aspects on message receive' do
    num_aspects = user.aspects.size

    2.times do |n|
      status_message = user2.post :status_message, :message => "store this #{n}!", :to => aspect2.id
    end

    user.aspects.size.should == num_aspects
  end

  context 'update posts' do
    it 'does not update posts not marked as mutable' do
      status = user.post :status_message, :message => "store this!", :to => aspect.id
      status.message = 'foo'
      xml = status.to_diaspora_xml

      zord(user2, user.person, xml)

      status.reload.message.should == 'store this!'
    end

    it 'updates posts marked as mutable' do
      photo = user.post(:photo, :user_file => uploaded_photo, :caption => "Original", :to => aspect.id)
      photo.caption = 'foo'
      xml = photo.to_diaspora_xml
      user2.reload

      zord(user2, user.person, xml)

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
      person = user2.person
      person.owner_id = nil
      person.save
      @status_message.user_refs = 1
      @status_message.save

      lambda {
        user.disconnected_by(user2.person)
      }.should change(Post, :count).by(-1)
    end

    it 'should keep track of user references for one person ' do
      @status_message.reload
      @status_message.user_refs.should == 1

      user.disconnect(user2.person)
      @status_message.reload
      @status_message.user_refs.should == 0
    end

    it 'should not override userrefs on receive by another person' do
      user3.activate_contact(user2.person, aspect3)
      xml = @status_message.to_diaspora_xml
      
      zord(user3, user2.person, xml)

      @status_message.reload
      @status_message.user_refs.should == 2

      user.disconnect(user2.person)
      @status_message.reload
      @status_message.user_refs.should == 1
    end
  end

  describe 'comments' do
    before do
      connect_users(user, aspect, user3, aspect3)
      @post = user.post :status_message, :message => "hello", :to => aspect.id

      xml = @post.to_diaspora_xml

      zord(user2, user.person, xml)
      zord(user3, user.person, xml)

      @comment = user3.comment('tada',:on => @post)
      @comment.post_creator_signature = @comment.sign_with_key(user.encryption_key)
      @xml = @comment.to_diaspora_xml
      @comment.delete
    end

    it 'should correctly attach the user already on the pod' do
      local_person = user3.person

      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = user2.raw_visible_posts.first
      post_in_db.comments.should == []

      zord(user2, user.person, @xml)

      post_in_db.reload

      post_in_db.comments.include?(@comment).should be true
      post_in_db.comments.first.person.should == local_person
    end

    it 'should correctly marshal a stranger for the downstream user' do
      remote_person = user3.person
      remote_person.delete
      user3.delete

      #stubs async webfinger
      Person.should_receive(:by_account_identifier).and_return{ |handle| if handle == user.person.diaspora_handle; user.person.save
        user.person; else; remote_person.save; remote_person; end }

      user2.reload.raw_visible_posts.size.should == 1
      post_in_db = user2.raw_visible_posts.first
      post_in_db.comments.should == []

      zord(user2, user.person, @xml)

      post_in_db.reload

      post_in_db.comments.include?(@comment).should be true
      post_in_db.comments.first.person.should == remote_person
    end
  end

  describe 'salmon' do
    let(:post){user.post :status_message, :message => "hello", :to => aspect.id}
    let(:salmon){user.salmon( post )}

    it 'should receive a salmon for a post' do
      salmon_xml = salmon.xml_for(user2.person)

      zord = Postzord::Receiver.new(user2, :salmon_xml => salmon_xml)
      zord.perform

      user2.visible_post_ids.include?(post.id).should be true
    end
  end
end
