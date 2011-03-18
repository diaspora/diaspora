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
    @user1  = alice
    @aspect = @user1.aspects.first

    @user2   = bob
    @aspect2 = @user2.aspects.first

    @user3   = eve
    @aspect3 = @user3.aspects.first

    @contact = @user1.contact_for(@user2.person)
  end

  it 'streams only one message to the everyone aspect when a multi-aspected contacts posts' do
    contact = @user1.contact_for(@user2.person)
    @user1.add_contact_to_aspect(contact, @user1.aspects.create(:name => "villains"))
    status = @user2.build_post(:status_message, :text => "Users do things", :to => @aspect2.id)
    Diaspora::WebSocket.stub!(:is_connected?).and_return(true)
    Diaspora::WebSocket.should_receive(:queue_to_user).exactly(:once)
    zord = Postzord::Receiver.new(@user1, :object => status, :person => @user2.person)
    zord.receive_object
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = @user2.post :status_message, :text => 'store this!', :to => @aspect2.id

    xml = status_message.to_diaspora_xml
    @user2.delete
    status_message.destroy

    lambda {
      receive_with_zord(@user1, @user2.person, xml)
    }.should change(Post,:count).by(1)
  end

  it 'should not create new aspects on message receive' do
    num_aspects = @user1.aspects.size

    2.times do |n|
      status_message = @user2.post :status_message, :text => "store this #{n}!", :to => @aspect2.id
    end

    @user1.aspects.size.should == num_aspects
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
      Notification.should_receive(:notify).with(@user1, anything(), @user2.person)
      Notification.should_receive(:notify).with(@user3, anything(), @user2.person)

      @sm = @user2.build_post(:status_message, :text => "@{#{@user1.name}; #{@user1.diaspora_handle}} stuff @{#{@user3.name}; #{@user3.diaspora_handle}}")
      @sm.stub!(:socket_to_user)
      @user2.add_to_streams(@sm, [@user2.aspects.first])
      @sm.save

      zord = Postzord::Receiver.new(@user1, :object => @sm, :person => @user2.person)
      zord.receive_object

      zord = Postzord::Receiver.new(@user3, :object => @sm, :person => @user2.person)
      zord.receive_object
    end

    it 'notifies users when receiving a mention in a post from a remote user' do
      @remote_person = Factory.create(:person, :diaspora_handle => "foobar@foobar.com")
      Contact.create!(:user => @user1, :person => @remote_person, :aspects => [@aspect], :pending => false)

      Notification.should_receive(:notify).with(@user1, anything(), @remote_person)

      @sm = Factory.build(:status_message, :text => "hello @{#{@user1.name}; #{@user1.diaspora_handle}}", :diaspora_handle => @remote_person.diaspora_handle, :author => @remote_person)
      @sm.stub!(:socket_to_user)
      @sm.save

      zord = Postzord::Receiver.new(@user1, :object => @sm, :person => @user2.person)
      zord.receive_object
    end

    it 'does not notify the mentioned user if the mentioned user is not friends with the post author' do
      Notification.should_not_receive(:notify).with(@user1, anything(), @user3.person)

      @sm = @user3.build_post(:status_message, :text => "should not notify @{#{@user1.name}; #{@user1.diaspora_handle}}")
      @sm.stub!(:socket_to_user)
      @user3.add_to_streams(@sm, [@user3.aspects.first])
      @sm.save

      zord = Postzord::Receiver.new(@user1, :object => @sm, :person => @user2.person)
      zord.receive_object
    end
  end

  context 'update posts' do
    it 'does not update posts not marked as mutable' do
      status = @user1.post :status_message, :text => "store this!", :to => @aspect.id
      status.text = 'foo'
      xml = status.to_diaspora_xml

      receive_with_zord(@user2, @user1.person, xml)

      status.reload.text.should == 'store this!'
    end

    it 'updates posts marked as mutable' do
      photo = @user1.post(:photo, :user_file => uploaded_photo, :text => "Original", :to => @aspect.id)
      photo.text = 'foo'
      xml = photo.to_diaspora_xml
      @user2.reload

      receive_with_zord(@user2, @user1.person, xml)

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
      @status_message = @user2.post :status_message, :text => "hi", :to => @aspect2.id
      @user1.reload
      @aspect.reload
    end

    it "adds a received post to the aspect and visible_posts array" do
      @user1.raw_visible_posts.include?(@status_message).should be_true
      @aspect.posts.include?(@status_message).should be_true
    end

    it 'removes posts upon disconnecting' do
      @user1.disconnect(@contact)
      @user1.reload
      @user1.raw_visible_posts.should_not include @status_message
    end

    context 'dependant delete' do
      before do
        @person = Factory(:person)
        @user1.activate_contact(@person, @aspect)
        @post = Factory.create(:status_message, :author => @person)
        @post.post_visibilities.should be_empty
        receive_with_zord(@user1, @person, @post.to_diaspora_xml)
        @aspect.post_visibilities.reset
        @aspect.posts(true).should include(@post)
        @post.post_visibilities.reset
      end

      it 'deletes a post if the noone links to it' do
        lambda {
          @user1.disconnected_by(@person)
        }.should change(Post, :count).by(-1)
      end

      it 'deletes post_visibilities on disconnected by' do
        lambda {
          @user1.disconnected_by(@person)
        }.should change{@post.post_visibilities(true).count}.by(-1)
      end
    end
    it 'should keep track of user references for one person ' do
      @status_message.reload
      @status_message.user_refs.should == 3

      @user1.disconnect(@contact)
      @status_message.reload
      @status_message.user_refs.should == 2
    end

    it 'should not override userrefs on receive by another person' do
      new_user = Factory(:user_with_aspect)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 3

      new_user.activate_contact(@user2.person, new_user.aspects.first)
      xml = @status_message.to_diaspora_xml

      receive_with_zord(new_user, @user2.person, xml)

      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 4

      @user1.disconnect(@contact)
      @status_message.post_visibilities.reset
      @status_message.user_refs.should == 3
    end
  end

  describe 'comments' do

    context 'remote' do
      before do
        connect_users(@user1, @aspect, @user3, @aspect3)
        @post = @user1.post :status_message, :text => "hello", :to => @aspect.id

        xml = @post.to_diaspora_xml

        receive_with_zord(@user2, @user1.person, xml)
        receive_with_zord(@user3, @user1.person, xml)

        @comment = @user3.comment('tada',:on => @post)
        @comment.parent_author_signature = @comment.sign_with_key(@user1.encryption_key)
        @xml = @comment.to_diaspora_xml
        @comment.delete
      end

      it 'should correctly attach the user already on the pod' do
        @user2.reload.raw_visible_posts.size.should == 1
        post_in_db = StatusMessage.find(@post.id)
        post_in_db.comments.should == []
        receive_with_zord(@user2, @user1.person, @xml)

        post_in_db.comments(true).first.author.should == @user3.person
      end

      it 'should correctly marshal a stranger for the downstream user' do
        remote_person = @user3.person.dup
        @user3.person.delete
        @user3.delete
        Person.where(:id => remote_person.id).delete_all
        Profile.where(:person_id => remote_person.id).delete_all
        remote_person.id = nil

        Person.should_receive(:by_account_identifier).twice.and_return{ |handle|
          if handle == @user1.person.diaspora_handle
            @user1.person.save
            @user1.person
          else
            remote_person.save(:validate => false)
            remote_person.profile = Factory(:profile, :person => remote_person)
            remote_person
          end
        }

        @user2.reload.raw_visible_posts.size.should == 1
        post_in_db = StatusMessage.find(@post.id)
        post_in_db.comments.should == []

        receive_with_zord(@user2, @user1.person, @xml)

        post_in_db.comments(true).first.author.should == remote_person
      end
    end

    context 'local' do
      before do
        @post = @user1.post :status_message, :text => "hello", :to => @aspect.id

        xml = @post.to_diaspora_xml

        receive_with_zord(@user2, @user1.person, xml)
        receive_with_zord(@user3, @user1.person, xml)
      end

      it 'does not raise a `Mysql2::Error: Duplicate entry...` exception on save' do
        @comment = @user2.comment('tada',:on => @post)
        @xml = @comment.to_diaspora_xml

        lambda {
            receive_with_zord(@user1, @user2.person, @xml)
        }.should_not raise_exception
      end
    end
  end


  describe 'receiving mulitple versions of the same post from a remote pod' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @post = Factory.build(:status_message, :text => 'hey', :guid => 12313123, :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
    end

    it 'does not update created_at or updated_at when two people save the same post' do
      @post = Factory.build(:status_message, :text => 'hey', :guid => 12313123, :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      sleep(2)
      old_time = Time.now
      receive_with_zord(@local_leia, @remote_raphael, xml)
      (Post.find_by_guid @post.guid).updated_at.should be < old_time
      (Post.find_by_guid @post.guid).created_at.should be < old_time
    end

    it 'does not update the post if a new one is sent with a new created_at' do
      @post = Factory.build(:status_message, :text => 'hey', :guid => 12313123, :author => @remote_raphael, :created_at => 5.days.ago)
      old_time = @post.created_at
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      @post = Factory.build(:status_message, :text => 'hey', :guid => 12313123, :author => @remote_raphael, :created_at => 2.days.ago)
      receive_with_zord(@local_luke, @remote_raphael, xml)
      (Post.find_by_guid @post.guid).created_at.day.should == old_time.day
    end
  end


  describe 'salmon' do
    let(:post){@user1.post :status_message, :text => "hello", :to => @aspect.id}
    let(:salmon){@user1.salmon( post )}

    it 'processes a salmon for a post' do
      salmon_xml = salmon.xml_for(@user2.person)

      zord = Postzord::Receiver.new(@user2, :salmon_xml => salmon_xml)
      zord.perform

      @user2.raw_visible_posts.include?(post).should be_true
    end
  end


  context 'retractions' do
    it 'should accept retractions' do
      message = @user2.post(:status_message, :text => "cats", :to => @aspect2.id)
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      lambda {
        zord = Postzord::Receiver.new(@user1, :person => @user2.person)
        zord.parse_and_receive(xml)
      }.should change(StatusMessage, :count).by(-1)
    end

    it "should activate the Person if I initiated a request to that url" do
      @user1.send_contact_request_to(@user3.person, @aspect)
      request = @user3.request_from(@user1.person)
      fantasy_resque do
        @user3.accept_and_respond(request.id, @aspect3.id)
      end
      @user1.reload
      @aspect.reload
      new_contact = @user1.contact_for(@user3.person)
      @aspect.contacts.include?(new_contact).should be true
      @user1.contacts.include?(new_contact).should be true
    end

    it 'should process retraction for a person' do
      retraction = Retraction.for(@user2)
      retraction_xml = retraction.to_diaspora_xml

      lambda {
        zord = Postzord::Receiver.new(@user1, :person => @user2.person)
        zord.parse_and_receive(retraction_xml)
      }.should change {
        @aspect.contacts(true).size }.by(-1)
    end

  end

  it 'should marshal a profile for a person' do
    #Create person
    person = @user2.person
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
    zord = Postzord::Receiver.new(@user1, :person => person)
    zord.parse_and_receive(xml)

    #Check that marshaled profile is the same as old profile
    person = Person.find(person.id)
    person.profile.first_name.should == new_profile.first_name
    person.profile.last_name.should == new_profile.last_name
    person.profile.image_url.should == new_profile.image_url
  end
end
