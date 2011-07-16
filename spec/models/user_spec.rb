#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  it 'should have a key' do
    alice.encryption_key.should_not be nil
  end

  describe 'overwriting people' do
    it 'does not overwrite old users with factory' do
      lambda {
        new_user = Factory.create(:user, :id => alice.id)
      }.should raise_error ActiveRecord::RecordNotUnique
    end

    it 'does not overwrite old users with create' do
          params = {:username => "ohai",
                    :email => "ohai@example.com",
                    :password => "password",
                    :password_confirmation => "password",
                    :person =>
                      {:profile =>
                        {:first_name => "O",
                         :last_name => "Hai"}
                      }
          }
          params[:id] = alice.id
      new_user = User.build(params)
      new_user.save
      new_user.persisted?.should be_true
      new_user.id.should_not == alice.id
    end
  end

  describe "validation" do
    describe "of associated person" do
      it "fails if person is not valid" do
        user = alice
        user.should be_valid

        user.person.serialized_public_key = nil
        user.person.should_not be_valid
        user.should_not be_valid

        user.errors.full_messages.count.should == 1
        user.errors.full_messages.first.should =~ /Person is invalid/i
      end
    end

    describe "of username" do
      it "requires presence" do
        alice.username = nil
        alice.should_not be_valid
      end

      it "requires uniqueness" do
        alice.username = eve.username
        alice.should_not be_valid
      end

      it "downcases username" do
        user = Factory.build(:user, :username => "WeIrDcAsE")
        user.should be_valid
        user.username.should == "weirdcase"
      end

      it "fails if the requested username is only different in case from an existing username" do
        alice.username = eve.username.upcase
        alice.should_not be_valid
      end

      it "strips leading and trailing whitespace" do
        user = Factory.build(:user, :username => "      janie   ")
        user.should be_valid
        user.username.should == "janie"
      end

      it "fails if there's whitespace in the middle" do
        alice.username = "bobby tables"
        alice.should_not be_valid
      end

      it 'can not contain non url safe characters' do
        alice.username = "kittens;"
        alice.should_not be_valid
      end

      it 'should not contain periods' do
        alice.username = "kittens."
        alice.should_not be_valid
      end

      it "can be 32 characters long" do
        alice.username = "hexagoooooooooooooooooooooooooon"
        alice.should be_valid
      end

      it "cannot be 33 characters" do
        alice.username =  "hexagooooooooooooooooooooooooooon"
        alice.should_not be_valid
      end
    end

    describe "of email" do
      it "requires email address" do
        alice.email = nil
        alice.should_not be_valid
      end

      it "requires a unique email address" do
        alice.email = eve.email
        alice.should_not be_valid
      end
    end

    describe "of language" do
      after do
        I18n.locale = :en
      end

      it "requires availability" do
        alice.language = 'some invalid language'
        alice.should_not be_valid
      end

      it "should save with current language if blank" do
        I18n.locale = :fr
        user = Factory(:user, :language => nil)
        user.language.should == 'fr'
      end
    end
  end

  describe ".build" do
    context 'with valid params' do
      before do
        params = {:username => "ohai",
                  :email => "ohai@example.com",
                  :password => "password",
                  :password_confirmation => "password",
                  :person =>
                    {:profile =>
                      {:first_name => "O",
                       :last_name => "Hai"}
                    }
        }
        @user = User.build(params)
      end

      it "does not save" do
        @user.persisted?.should be_false
        @user.person.persisted?.should be_false
        User.find_by_username("ohai").should be_nil
      end

      it 'saves successfully' do
        @user.should be_valid
        @user.save.should be_true
        @user.persisted?.should be_true
        @user.person.persisted?.should be_true
        User.find_by_username("ohai").should == @user
      end
    end

    describe "with invalid params" do
      before do
        @invalid_params = {
          :username => "ohai",
          :email => "ohai@example.com",
          :password => "password",
          :password_confirmation => "wrongpasswordz",
          :person => {:profile => {:first_name => "", :last_name => ""}}}
      end

      it "raises no error" do
        lambda { User.build(@invalid_params) }.should_not raise_error
      end

      it "does not save" do
        User.build(@invalid_params).save.should be_false
      end

      it 'does not save a person' do
        lambda { User.build(@invalid_params) }.should_not change(Person, :count)
      end

      it 'does not generate a key' do
        User.should_receive(:generate_key).exactly(0).times
        User.build(@invalid_params)
      end
    end

    describe "with malicious params" do
      let(:person) {Factory.create :person}
      before do
        @invalid_params = {:username => "ohai",
                  :email => "ohai@example.com",
                  :password => "password",
                  :password_confirmation => "password",
                  :person =>
                    {:id => person.id,
                      :profile =>
                      {:first_name => "O",
                       :last_name => "Hai"}
                    }
        }
      end

      it "does not assign it to the person" do
        User.build(@invalid_params).person.id.should_not == person.id
      end
    end
  end

  describe "#can_add?" do
    it "returns true if there is no existing connection" do
      alice.can_add?(eve.person).should be_true
    end

    it "returns false if the user and the person are the same" do
      alice.can_add?(alice.person).should be_false
    end

    it "returns false if the users are already connected" do
      alice.can_add?(bob.person).should be_false
    end

    it "returns false if the user has already sent a request to that person" do
      alice.share_with(eve.person, alice.aspects.first)
      alice.reload
      eve.reload
      alice.can_add?(eve.person).should be_false
    end
  end

  describe 'update_user_preferences' do
    before do
      @pref_count = UserPreference::VALID_EMAIL_TYPES.count
    end

    it 'unsets disable mail and makes the right amount of prefs' do
      alice.disable_mail = true
      proc {
        alice.update_user_preferences({})
      }.should change(alice.user_preferences, :count).by(@pref_count)
    end

    it 'still sets new prefs to false on update' do
      alice.disable_mail = true
      proc {
        alice.update_user_preferences({'mentioned' => false})
      }.should change(alice.user_preferences, :count).by(@pref_count-1)
      alice.reload.disable_mail.should be_false
    end
  end

  describe ".find_for_authentication" do
    it 'finds a user' do
      User.find_for_authentication(:username => alice.username).should == alice
    end

    it "does not preserve case" do
      User.find_for_authentication(:username => alice.username.upcase).should == alice
    end

    it 'errors out when passed a non-hash' do
      lambda {
        User.find_for_authentication(alice.username)
      }.should raise_error
    end
  end

  describe '#update_profile' do
    before do
      @params = {
        :first_name => 'bob',
        :last_name => 'billytown',
      }
    end

    it 'dispatches the profile when tags are set' do
      @params = {:tags => '#what #hey'}
      mailman = Postzord::Dispatch.new(alice, Profile.new)
      Postzord::Dispatch.should_receive(:new).and_return(mailman)
      mailman.should_receive(:deliver_to_local)
      alice.update_profile(@params).should be_true
    end

    it 'sends a profile to their contacts' do
      mailman = Postzord::Dispatch.new(alice, Profile.new)
      Postzord::Dispatch.should_receive(:new).and_return(mailman)
      mailman.should_receive(:deliver_to_local)
      alice.update_profile(@params).should be_true
    end

    it 'updates names' do
      alice.update_profile(@params).should be_true
      alice.reload.profile.first_name.should == 'bob'
    end

    it 'updates image_url' do
      params = {:image_url => "http://clown.com"}

      alice.update_profile(params).should be_true
      alice.reload.profile.image_url.should == "http://clown.com"
    end

    context 'passing in a photo' do
      before do
        fixture_filename  = 'button.png'
        fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture_filename)
        image = File.open(fixture_name)
        @photo = Photo.diaspora_initialize(:author => alice.person, :user_file => image)
        @photo.save!
        @params = {:photo => @photo}
      end

      it 'updates image_url' do
        alice.update_profile(@params).should be_true
        alice.reload

        alice.profile.image_url.should =~ Regexp.new(@photo.url(:thumb_large))
        alice.profile.image_url_medium.should =~ Regexp.new(@photo.url(:thumb_medium))
        alice.profile.image_url_small.should =~ Regexp.new(@photo.url(:thumb_small))
      end

      it 'unpends the photo' do
        @photo.pending = true
        @photo.save!
        @photo.reload
        alice.update_profile(@params).should be true
        @photo.reload.pending.should be_false
      end
    end
  end

  describe '#update_post' do
    it 'sends a notification to aspects' do
      m = mock()
      m.should_receive(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)
      photo = alice.build_post(:photo, :user_file => uploaded_photo, :text => "hello", :to => alice.aspects.first.id)
      alice.update_post(photo, :text => 'hellp')
    end
  end

  describe '#notify_if_mentioned' do
    before do
      @post = Factory.create(:status_message, :author => bob.person)
    end

    it 'notifies the user if the incoming post mentions them' do
      @post.should_receive(:mentions?).with(alice.person).and_return(true)
      @post.should_receive(:notify_person).with(alice.person)

      alice.notify_if_mentioned(@post)
    end

    it 'does not notify the user if the incoming post does not mention them' do
      @post.should_receive(:mentions?).with(alice.person).and_return(false)
      @post.should_not_receive(:notify_person)

      alice.notify_if_mentioned(@post)
    end

    it 'does not notify the user if the post author is not a contact' do
      @post = Factory.create(:status_message, :author => eve.person)
      @post.stub(:mentions?).and_return(true)
      @post.should_not_receive(:notify_person)

      alice.notify_if_mentioned(@post)
    end
  end

  describe 'account deletion' do
    describe '#remove_all_traces' do
      it 'should disconnect everyone' do
        alice.should_receive(:disconnect_everyone)
        alice.remove_all_traces
      end


      it 'should remove mentions' do
        alice.should_receive(:remove_mentions)
        alice.remove_all_traces
      end

      it 'should remove person' do
        alice.should_receive(:remove_person)
        alice.remove_all_traces
      end

      it 'should remove all aspects' do
        lambda {
          alice.remove_all_traces
        }.should change{ alice.aspects(true).count }.by(-1)
      end
    end

    describe '#destroy' do
      it 'removes invitations from the user' do
        alice.invite_user alice.aspects.first.id, 'email', 'blah@blah.blah'
        lambda {
          alice.destroy
        }.should change {alice.invitations_from_me(true).count }.by(-1)
      end

      it 'removes invitations to the user' do
        Invitation.create(:sender_id => eve.id, :recipient_id => alice.id, :aspect_id => eve.aspects.first.id)
        lambda {
          alice.destroy
        }.should change {alice.invitations_to_me(true).count }.by(-1)
      end

      it 'removes all service connections' do
        Services::Facebook.create(:access_token => 'what', :user_id => alice.id)
        lambda {
          alice.destroy
        }.should change {
          alice.services.count
        }.by(-1)
      end
    end

    describe '#remove_person' do
      it 'should remove the person object' do
        person = alice.person
        alice.remove_person
        person.reload
        person.should be_nil
      end

      it 'should remove the posts' do
        message = alice.post(:status_message, :text => "hi", :to => alice.aspects.first.id)
        alice.reload
        alice.remove_person
        proc { message.reload }.should raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#remove_mentions' do
      it 'should remove the mentions' do
        person = alice.person
        sm =  Factory(:status_message)
        mention  = Mention.create(:person => person, :post=> sm)
        alice.reload
        alice.remove_mentions
        proc { mention.reload }.should raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#disconnect_everyone' do
      it 'has no error on a local friend who has deleted his account' do
        Job::DeleteAccount.perform(alice.id)
        lambda {
          bob.disconnect_everyone
        }.should_not raise_error
      end

      it 'has no error when the user has sent local requests' do
        alice.share_with(eve.person, alice.aspects.first)
        lambda {
          alice.disconnect_everyone
        }.should_not raise_error
      end

      it 'sends retractions to remote poeple' do
        person = eve.person
        eve.delete
        person.owner_id = nil
        person.save
        alice.contacts.create(:person => person, :aspects => [alice.aspects.first])

        alice.should_receive(:disconnect).once
        alice.disconnect_everyone
      end

      it 'disconnects local people' do
        lambda {
          alice.remove_all_traces
        }.should change{bob.reload.contacts.count}.by(-1)
      end

      it 'removes all contacts' do
        lambda {
          alice.disconnect_everyone
        }.should change {
          alice.contacts.count
        }.by(-1)
      end
    end
  end

  describe '#mail' do
    it 'enqueues a mail job' do
      alice.disable_mail = false
      alice.save

      Resque.should_receive(:enqueue).with(Job::MailStartedSharing, alice.id, 'contactrequestid').once
      alice.mail(Job::MailStartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not enqueue a mail job if the correct corresponding job has a prefrence entry' do
      alice.user_preferences.create(:email_type => 'started_sharing')
      Resque.should_not_receive(:enqueue)
      alice.mail(Job::MailStartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not send a mail if disable_mail is set to true' do
       alice.disable_mail = true
       alice.save
       alice.reload
       Resque.should_not_receive(:enqueue)
      alice.mail(Job::MailStartedSharing, alice.id, 'contactrequestid')
    end
  end

  context "aspect management" do
    before do
      @contact = alice.contact_for(bob.person)
      @aspect1 = alice.aspects.create(:name => 'two')
    end

    describe "#add_contact_to_aspect" do
      it 'adds the contact to the aspect' do
        lambda {
          alice.add_contact_to_aspect(@contact, @aspect1)
        }.should change(@aspect1.contacts, :count).by(1)
      end

      it 'returns true if they are already in the aspect' do
        alice.add_contact_to_aspect(@contact, alice.aspects.first).should be_true
      end
    end

    context 'moving and removing posts' do
      describe 'User#move_contact' do
        it 'should be able to move a contact from one of users existing aspects to another' do
          alice.move_contact(bob.person, @aspect1, alice.aspects.first)

          alice.aspects.first.contacts(true).include?(@contact).should be_false
          @aspect1.contacts(true).include?(@contact).should be_true
        end

        it "should not move a person who is not a contact" do
          non_contact = eve.person

          proc{
            alice.move_contact(non_contact, @aspect1, alice.aspects.first)
          }.should raise_error

          alice.aspects.first.contacts.where(:person_id => non_contact.id).should be_empty
          @aspect1.contacts.where(:person_id => non_contact.id).should be_empty
        end

        it 'does not try to delete if add person did not go through' do
          alice.should_receive(:add_contact_to_aspect).and_return(false)
          alice.should_not_receive(:delete_person_from_aspect)
          alice.move_contact(bob.person, @aspect1, alice.aspects.first)
        end
      end
    end
  end

  context 'likes' do
    before do
      @message = alice.post(:status_message, :text => "cool", :to => alice.aspects.first)
      @message2 = bob.post(:status_message, :text => "uncool", :to => bob.aspects.first)
      @like = alice.like(true, :target => @message)
      @like2 = bob.like(true, :target => @message)
    end

    describe '#like_for' do
      it 'returns the correct like' do
        alice.like_for(@message).should == @like
        bob.like_for(@message).should == @like2
      end

      it "returns nil if there's no like" do
        alice.like_for(@message2).should be_nil
      end
    end

    describe '#liked?' do
      it "returns true if there's a like" do
        alice.liked?(@message).should be_true
        bob.liked?(@message).should be_true
      end

      it "returns false if there's no like" do
        alice.liked?(@message2).should be_false
      end
    end
  end
end
