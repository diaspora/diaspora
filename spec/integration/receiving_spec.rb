#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'a user receives a post', :type => :request do

  def receive_with_zord(user, person, xml)
    zord = Postzord::Receiver::Private.new(user, :person => person)
    zord.parse_and_receive(xml)
  end

  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first
    @eves_aspect = eve.aspects.where(:name => "generic").first

    @contact = alice.contact_for(bob.person)
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = bob.post :status_message, :text => 'store this!', :to => @bobs_aspect.id

    xml = status_message.to_diaspora_xml
    bob.delete
    status_message.destroy

    expect {
      receive_with_zord(alice, bob.person, xml)
    }.to change(Post,:count).by(1)
  end

  it 'should not create new aspects on message receive' do
    num_aspects = alice.aspects.size

    2.times do |n|
      status_message = bob.post :status_message, :text => "store this #{n}!", :to => @bobs_aspect.id
    end

    expect(alice.aspects.size).to eq(num_aspects)
  end

  it "should show bob's post to alice" do
    inlined_jobs do |queue|
      sm = bob.build_post(:status_message, :text => "hi")
      sm.save!
      bob.aspects.reload
      bob.add_to_streams(sm, [@bobs_aspect])
      queue.drain_all
      bob.dispatch_post(sm, :to => @bobs_aspect)
    end

    expect(alice.visible_shareables(Post).count(:all)).to eq(1)
  end

  context 'with mentions, ' do
    it 'adds the notifications for the mentioned users regardless of the order they are received' do
      expect(Notification).to receive(:notify).with(alice, anything(), bob.person)
      expect(Notification).to receive(:notify).with(eve, anything(), bob.person)

      @sm = bob.build_post(:status_message, :text => "@{#{alice.name}; #{alice.diaspora_handle}} stuff @{#{eve.name}; #{eve.diaspora_handle}}")
      bob.add_to_streams(@sm, [bob.aspects.first])
      @sm.save

      zord = Postzord::Receiver::Private.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object

      zord = Postzord::Receiver::Private.new(eve, :object => @sm, :person => bob.person)
      zord.receive_object
    end

    it 'notifies local users who are mentioned' do
      @remote_person = FactoryGirl.create(:person, :diaspora_handle => "foobar@foobar.com")
      Contact.create!(:user => alice, :person => @remote_person, :aspects => [@alices_aspect])

      expect(Notification).to receive(:notify).with(alice, anything(), @remote_person)

      @sm = FactoryGirl.create(:status_message, :text => "hello @{#{alice.name}; #{alice.diaspora_handle}}", :diaspora_handle => @remote_person.diaspora_handle, :author => @remote_person)
      @sm.save

      zord = Postzord::Receiver::Private.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object
    end

    it 'does not notify the mentioned user if the mentioned user is not friends with the post author' do
      expect(Notification).not_to receive(:notify).with(alice, anything(), eve.person)

      @sm = eve.build_post(:status_message, :text => "should not notify @{#{alice.name}; #{alice.diaspora_handle}}")
      eve.add_to_streams(@sm, [eve.aspects.first])
      @sm.save

      zord = Postzord::Receiver::Private.new(alice, :object => @sm, :person => bob.person)
      zord.receive_object
    end
  end

  context 'update posts' do
    it 'does not update posts not marked as mutable' do
      status = alice.post :status_message, :text => "store this!", :to => @alices_aspect.id
      status.text = 'foo'
      xml = status.to_diaspora_xml

      receive_with_zord(bob, alice.person, xml)

      expect(status.reload.text).to eq('store this!')
    end

    it 'updates posts marked as mutable' do
      photo = alice.post(:photo, :user_file => uploaded_photo, :text => "Original", :to => @alices_aspect.id)
      photo.text = 'foo'
      xml = photo.to_diaspora_xml
      bob.reload

      receive_with_zord(bob, alice.person, xml)

      expect(photo.reload.text).to match(/foo/)
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
     expect(p.tags(true).count).to eq(3)
   end
  end

  describe 'post refs' do
    before do
      @status_message = bob.post(:status_message, :text => "hi", :to => @bobs_aspect.id)
      alice.reload
      @alices_aspect.reload
      @contact = alice.contact_for(bob.person)
    end

    it "adds a received post to the the contact" do
      expect(alice.visible_shareables(Post)).to include(@status_message)
      expect(@contact.posts).to include(@status_message)
    end

    it 'removes posts upon forceful removal' do
      alice.remove_contact(@contact, :force => true)
      alice.reload
      expect(alice.visible_shareables(Post)).not_to include @status_message
    end

    context 'dependent delete' do
      it 'deletes share_visibilities on disconnected by' do
        @person = FactoryGirl.create(:person)
        alice.contacts.create(:person => @person, :aspects => [@alices_aspect])

        @post = FactoryGirl.create(:status_message, :author => @person)
        expect(@post.share_visibilities).to be_empty
        receive_with_zord(alice, @person, @post.to_diaspora_xml)
        @contact = alice.contact_for(@person)
        @contact.share_visibilities.reset
        expect(@contact.posts(true)).to include(@post)
        @post.share_visibilities.reset

        expect {
          alice.disconnected_by(@person)
        }.to change{@post.share_visibilities(true).count}.by(-1)
      end
    end
  end

  describe 'comments' do

    context 'remote' do
      before do
        inlined_jobs do |queue|
          connect_users(alice, @alices_aspect, eve, @eves_aspect)
          @post = alice.post(:status_message, :text => "hello", :to => @alices_aspect.id)

          xml = @post.to_diaspora_xml

          receive_with_zord(bob, alice.person, xml)
          receive_with_zord(eve, alice.person, xml)

          comment = eve.comment!(@post, 'tada')
          queue.drain_all
          # After Eve creates her comment, it gets sent to Alice, who signs it with her private key
          # before relaying it out to the contacts on the top-level post
          comment.parent_author_signature = comment.sign_with_key(alice.encryption_key)
          @xml = comment.to_diaspora_xml
          comment.delete

          comment_with_whitespace = alice.comment!(@post, '   I cannot lift my thumb from the spacebar  ')
          queue.drain_all
          @xml_with_whitespace = comment_with_whitespace.to_diaspora_xml
          @guid_with_whitespace = comment_with_whitespace.guid
          comment_with_whitespace.delete
        end
      end

      it 'should receive a relayed comment with leading whitespace' do
        expect(eve.reload.visible_shareables(Post).size).to eq(1)
        post_in_db = StatusMessage.find(@post.id)
        expect(post_in_db.comments).to eq([])
        receive_with_zord(eve, alice.person, @xml_with_whitespace)

        expect(post_in_db.comments(true).first.guid).to eq(@guid_with_whitespace)
      end

      it 'should correctly attach the user already on the pod' do
        expect(bob.reload.visible_shareables(Post).size).to eq(1)
        post_in_db = StatusMessage.find(@post.id)
        expect(post_in_db.comments).to eq([])
        receive_with_zord(bob, alice.person, @xml)

        expect(post_in_db.comments(true).first.author).to eq(eve.person)
      end

      it 'should correctly marshal a stranger for the downstream user' do
        remote_person = eve.person.dup
        eve.person.delete
        eve.delete
        Person.where(:id => remote_person.id).delete_all
        Profile.where(:person_id => remote_person.id).delete_all
        remote_person.attributes.delete(:id) # leaving a nil id causes it to try to save with id set to NULL in postgres

        m = double()
        expect(Webfinger).to receive(:new).twice.with(eve.person.diaspora_handle).and_return(m)
        remote_person.save(:validate => false)
        remote_person.profile = FactoryGirl.create(:profile, :person => remote_person)
        expect(m).to receive(:fetch).twice.and_return(remote_person)

        expect(bob.reload.visible_shareables(Post).size).to eq(1)
        post_in_db = StatusMessage.find(@post.id)
        expect(post_in_db.comments).to eq([])

        receive_with_zord(bob, alice.person, @xml)

        expect(post_in_db.comments(true).first.author).to eq(remote_person)
      end
    end

    context 'local' do
      before do
        @post = alice.post :status_message, :text => "hello", :to => @alices_aspect.id

        xml = @post.to_diaspora_xml

        alice.share_with(eve.person, alice.aspects.first)

        receive_with_zord(bob, alice.person, xml)
        receive_with_zord(eve, alice.person, xml)
      end

      it 'does not raise a `Mysql2::Error: Duplicate entry...` exception on save' do
        inlined_jobs do
          @comment = bob.comment!(@post, 'tada')
          @xml = @comment.to_diaspora_xml

          expect {
            receive_with_zord(alice, bob.person, @xml)
          }.to_not raise_exception
        end
      end
    end
  end


  describe 'receiving mulitple versions of the same post from a remote pod' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @post = FactoryGirl.create(:status_message, :text => 'hey', :guid => '12313123', :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
    end

    it 'does not update created_at or updated_at when two people save the same post' do
      @post = FactoryGirl.build(:status_message, :text => 'hey', :guid => '12313123', :author=> @remote_raphael, :created_at => 5.days.ago, :updated_at => 5.days.ago)
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      old_time = Time.now+1
      receive_with_zord(@local_leia, @remote_raphael, xml)
      expect((Post.find_by_guid @post.guid).updated_at).to be < old_time
      expect((Post.find_by_guid @post.guid).created_at).to be < old_time
    end

    it 'does not update the post if a new one is sent with a new created_at' do
      @post = FactoryGirl.build(:status_message, :text => 'hey', :guid => '12313123', :author => @remote_raphael, :created_at => 5.days.ago)
      old_time = @post.created_at
      xml = @post.to_diaspora_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      @post = FactoryGirl.build(:status_message, :text => 'hey', :guid => '12313123', :author => @remote_raphael, :created_at => 2.days.ago)
      receive_with_zord(@local_luke, @remote_raphael, xml)
      expect((Post.find_by_guid @post.guid).created_at.day).to eq(old_time.day)
    end
  end


  describe 'salmon' do
    let(:post){alice.post :status_message, :text => "hello", :to => @alices_aspect.id}
    let(:salmon){alice.salmon( post )}

    it 'processes a salmon for a post' do
      salmon_xml = salmon.xml_for(bob.person)

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      expect(bob.visible_shareables(Post).include?(post)).to be true
    end
  end


  context 'retractions' do
    let(:message) { bob.post(:status_message, text: "cats", to: @bobs_aspect.id) }
    let(:zord) { Postzord::Receiver::Private.new(alice, person: bob.person) }

    it 'should accept retractions' do
      retraction = Retraction.for(message)
      xml = retraction.to_diaspora_xml

      expect {
        zord.parse_and_receive(xml)
      }.to change(StatusMessage, :count).by(-1)
    end

    it 'should accept relayable retractions' do
      comment = bob.comment! message, "and dogs"
      retraction = RelayableRetraction.build(bob, comment)
      xml = retraction.to_diaspora_xml

      expect {
        zord.parse_and_receive xml
      }.to change(Comment, :count).by(-1)
    end

    it 'should accept signed retractions for public posts' do
      message = bob.post(:status_message, text: "cats", public: true)
      retraction = SignedRetraction.build(bob, message)
      salmon = Postzord::Dispatcher::Public.salmon bob, retraction.to_diaspora_xml
      xml = salmon.xml_for alice.person
      zord = Postzord::Receiver::Public.new xml

      expect {
        zord.receive!
      }.to change(Post, :count).by(-1)
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
    zord = Postzord::Receiver::Private.new(alice, :person => person)
    zord.parse_and_receive(xml)

    #Check that marshaled profile is the same as old profile
    person = Person.find(person.id)
    expect(person.profile.first_name).to eq(new_profile.first_name)
    expect(person.profile.last_name).to eq(new_profile.last_name)
    expect(person.profile.image_url).to eq(new_profile.image_url)
  end
end
