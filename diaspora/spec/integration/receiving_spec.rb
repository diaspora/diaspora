#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'a user receives a post' do

  def receive_with_zord(user, person, xml)
    zord = Postzord::Receiver.new(user, :person => person)
    zord.parse_and_receive(xml)
  end

  before do
    @aspect = alice.aspects.first
    @aspect2 = bob.aspects.first
    @aspect3 = eve.aspects.first

    @contact = alice.contact_for(bob.person)
  end

  it 'streams only one message to the everyone aspect when a multi-aspected contacts posts' do
    contact = alice.contact_for(bob.person)
    alice.add_contact_to_aspect(contact, alice.aspects.create(:name => "villains"))
    status = bob.build_post(:status_message, :text => "Users do things", :to => @aspect2.id)
    Diaspora::WebSocket.stub!(:is_connected?).and_return(true)
    Diaspora::WebSocket.should_receive(:queue_to_user).exactly(:once)
    zord = Postzord::Receiver.new(alice, :object => status, :person => bob.person)
    zord.receive_object
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = bob.post :status_message, :text => 'store this!', :to => @aspect2.id

    xml = status_message.to_diaspora_xml
    bob.delete
    status_message.destroy

    lambda {
      receive_with_zord(alice, bob.person, xml)
    }.should change(Post,:count).by(1)
  end

  it 'should not create new aspects on message receive' do
    num_aspects = alice.aspects.size

    2.times do |n|
      status_message = bob.post :status_message, :text => "store this #{n}!", :to => @aspect2.id
    end

    alice.aspects.size.should == num_aspects
  end

  it "should show bob's post to alice" do
    fantasy_resque do
      sm = bob.build_post(:status_message, :text => "hi")
      sm.save!
      sm.stub!(:socket_to_user)
      bob.aspects.reload
      bob.add_to_streams(sm, [bob.aspects.first])
      bob.dispatch_post(sm, :to => bob.aspects.first)
    end

    alice.visible_posts.count.should == 1
  end

  context 'mentions' do
    it 'adds the notifications for the mentioned users regardless of the order they are received' do
      Notification.should_receive(:notify).with(alice, anything(), bob.person)
      Notification.should_receive(:notify).with(eve, anything(), bob.person)

      @sm = bob.build_post(:status_message, :text => "@{#{alice.name}; #{alice.diaspora_handle}} stuff @{#{eve.name}; #{eve.diaspora_handle}}")
      @sm.stub!(:socket_to_user)
      bob.add_to_streams(@sm, [bob.aspects.first])
      @sm.save

      zord = Postzord::Receiver.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object

      zord = Postzord::Receiver.new(eve, :object => @sm, :person => bob.person)
      zord.receive_object
    end

    it 'notifies users when receiving a mention in a post from a remote user' do
      @remote_person = Factory.create(:person, :diaspora_handle => "foobar@foobar.com")
      Contact.create!(:user => alice, :person => @remote_person, :aspects => [@aspect])

      Notification.should_receive(:notify).with(alice, anything(), @remote_person)

      @sm = Factory.build(:status_message, :text => "hello @{#{alice.name}; #{alice.diaspora_handle}}", :diaspora_handle => @remote_person.diaspora_handle, :author => @remote_person)
      @sm.stub!(:socket_to_user)
      @sm.save

      zord = Postzord::Receiver.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object
    end

    it 'does not notify the mentioned user if the mentioned user is not friends with the post author' do
      Notification.should_not_receive(:notify).with(alice, anything(), eve.person)

      @sm = eve.build_post(:status_message, :text => "should not notify @{#{alice.name}; #{alice.diaspora_handle}}")
      @sm.stub!(:socket_to_user)
      eve.add_to_streams(@sm, [eve.aspects.first])
      @sm.save

      zord = Postzord::Receiver.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object
    end
  end

  context 'update posts' do
    it 'does not update posts not marked as mutable' do
      status = alice.post :status_message, :text => "store this!", :to => @aspect.id
      status.text = 'foo'
      xml = status.to_diaspora_xml

      receive_with_zord(bob, alice.person, xml)

      status.reload.text.should == 'store this!'
    end

    it 'updates posts marked as mutable' do
      photo = alice.post(:photo, :user_file => uploaded_photo, :text => "Original", :to => @aspect.id)
      photo.text = 'foo'
      xml = photo.to_diaspora_xml
      bob.reload

      receive_with_zord(bob, alice.person, xml)

      photo.reload.text.should match(/foo/)
    end
  end

  describe 'profiles' do
   it 'federates tags' do
     luke, leia, raph = set_up_friends
     raph.profile.diaspora_handle = "raph@remote.net"
     raph.profile.save!
     p = raph.profile

     p.tag_string = "#big #rafi #style"
     p.receive(luke, raph)
     p.tags(true).count.should == 3
   end
  end

  describe 'post refs' do
    before do
      @status_message = bob.post(:status_message, :text => "hi", :to => @aspect2.id)
      alice.reload
      @aspect.reload
      @contact = alice.contact_for(bob.person)
    end

    it "adds a received post to the the contact" do
      alice.visible_posts.should include(@status_message)
      @contact.posts.should include(@status_message)
    end

    it 'removes posts upon forceful removal' do
      alice.remove_contact(@contact, :force => true)
      alice.reload
      alice.visible_posts.should_not include @status_message
    end

    context 'dependant delete' do
      before do
        @person = Factory(:person)
        alice.contacts.create(:person => @person, :aspects => [@aspect])

        @post = Factory.create(:status_message, :author => @person)
        @post.post_visibilities.should be_empty
        receive_with_zord(alice, @person, @post.to_diaspora_xml)
        @contact = alice.contact_for(@person)
        @contact.post_visibilities.reset
        @contact.posts(true).should include(@post)
        @post.post_visibilities.reset
      end

      it 'deletes a post if the no one links to it' do
        lambda {
          alice.disconnected_by(@person)
        }.should change(Post, :count).by(-1)
      end

      it 'deletes post_visibilities on disconnected by' do
        lambda {
          alice.disconnected_by(@person)
        }.should change{@post.post_visibilities(true).count}.by(-1)
      end
    end

    it 'should keep track of user references for one person ' do
      @status_message.reload
      @status_message.user_refs.should == 3
      @status_message.contacts(true).should include(@contact)

      alice.remove_contact(@contact, :force => true)
      @status_message.reload
      @status_message.contacts(true).should_not include(@contact)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 2
    end

    it 'should not override userrefs on receive by another person' do
      new_user = Factory(:user_with_aspect)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 3

      new_user.contacts.create(:person => bob.person, :aspects => [new_user.aspects.first])
      xml = @status_message.to_diaspora_xml

      receive_with_zord(new_user, bob.person, xml)

      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 4

      alice.remove_contact(@contact, :force => true)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 3
    end
  end

  describe 'comments' do

    context 'remote' do
      before do
        connect_users(alice, @aspect, eve, @aspect3)
        @post = alice.post(:status_message, :text => "hello", :to => @aspect.id)

        xml = @post.to_diaspora_xml

        receive_with_zord(bob, alice.person, xml)
        receive_with_zord(eve, alice.person, xml)

        @comment = eve.comment('tada',:post => @post)
        @comment.parent_author_signature = @comment.sign_with_key(alice.encryption_key)
        @xml = @comment.to_diaspora_xml
        @comment.delete
      end

      it 'should correctly attach the user already on the pod' do
        bob.reload.visible_posts.size.should == 1
        post_in_db = StatusMessage.find(@post.id)
        post_in_db.comments.should == []
        receive_with_zord(bob, alice.person, @xml)

        post_in_db.comments(true).first.author.should == eve.person
      end

      it 'should correctly marshal a stranger for the downstream user' do
        remote_person = eve.person.dup
        eve.person.delete
        eve.delete
        Person.where(:id => remote_person.id).delete_all
        Profile.where(:person_id => remote_person.id).delete_all
        remote_person.id = nil

        Person.should_receive(:by_account_identifier).twice.and_return{ |handle|
          if handle == alice.person.diaspora_handle
            alice.person.save
            alice.person
          else
            remote_person.save(:validate => false)
            remote_person.profile = Factory(:profile, :person => remote_person)
            remote_person
          end
        }

        bob.reload.visible_posts.size.should == 1
        post_in_db = StatusMessage.find(@post.id)
        post_in_db.comments.should == []

        receive_with_zord(bob, alice.person, @xml)

        post_in_db.comments(true).first.author.should == remote_person
      end
    end

    context 'local' do
      before do
        @post = alice.post :status_message, :text => "hello", :to => @aspect.id

        xml = @post.to_diaspora_xml

        alice.share_with(eve.person, alice.aspects.first)

        receive_with_zord(bob, alice.person, xml)
        receive_with_zord(eve, alice.person, xml)
      end

      it 'does not raise a `Mysql2::Error: Duplicate entry...` exception on save' do
        @comment = bob.comment('tada',:post => @post)
        @xml = @comment.to_diaspora_xml

        lambda {
          receive_with_zord(alice, bob.person, @xml)
        }.should_not raise_exception
      end
    end
  end


  describe 'receiving mulitple versions of the same post from a remote pod' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @post = Factory.build(:status_message, :text => 'hey', :guid => '12313123', :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
    end

    it 'does not update created_at or updated_at when two people save the same post' do
      @post = Factory.build(:status_message, :text => 'hey', :guid => '12313123', :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      old_time = Time.now+1
      receive_with_zord(@local_leia, @remote_raphael, xml)
      (Post.find_by_guid @post.guid).updated_at.should be < old_time
      (Post.find_by_guid @post.guid).created_at.should be < old_time
    end

    it 'does not update the post if a new one is sent with a new created_at' do
      @post = Factory.build(:status_message, :text => 'hey', :guid => '12313123', :author => @remote_raphael, :created_at => 5.days.ago)
      old_time = @post.created_at
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      @post = Factory.build(:status_message, :text => 'hey', :guid => '12313123', :author => @remote_raphael, :created_at => 2.days.ago)
      receive_with_zord(@local_luke, @remote_raphael, xml)
      (Post.find_by_guid @post.guid).created_at.day.should == old_time.day
    end
  end


  describe 'salmon' do
    let(:post){alice.post :status_message, :text => "hello", :to => @aspect.id}
    let(:salmon){alice.salmon( post )}

    it 'processes a salmon for a post' do
      salmon_xml = salmon.xml_for(bob.person)

      zord = Postzord::Receiver.new(bob, :salmon_xml => salmon_xml)
      zord.perform

      bob.visible_posts.include?(post).should be_true
    end
  end


  context 'retractions' do
    it 'should accept retractions' do
      message = bob.post(:status_message, :text => "cats", :to => @aspect2.id)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      lambda {
        zord = Postzord::Receiver.new(alice, :person => bob.person)
        zord.parse_and_receive(xml)
      }.should change(StatusMessage, :count).by(-1)
    end
  end

  it 'should marshal a profile for a person' do
    #Create person
    person = bob.person
    id = person.id
    person.profile.delete
    person.profile = Profile.new(:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com", :person_id => person.id)
    person.save

    #Cache profile for checking against marshaled profile
    new_profile = person.profile.dup
    new_profile.first_name = 'boo!!!'

    #Build xml for profile
    xml = new_profile.to_diaspora_xml

    #Marshal profile
    zord = Postzord::Receiver.new(alice, :person => person)
    zord.parse_and_receive(xml)

    #Check that marshaled profile is the same as old profile
    person = Person.find(person.id)
    person.profile.first_name.should == new_profile.first_name
    person.profile.last_name.should == new_profile.last_name
    person.profile.image_url.should == new_profile.image_url
  end
end
