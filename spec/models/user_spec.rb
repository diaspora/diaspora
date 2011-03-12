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
        user = Factory.build(:user)
        user.should be_valid

        user.person.serialized_public_key = nil
        user.person.should_not be_valid
        user.should_not be_valid

        user.errors.full_messages.count.should == 1
        user.errors.full_messages.first.should =~ /Person is invalid/i
      end
    end

    describe "of passwords" do
      it "fails if password doesn't match confirmation" do
        user = Factory.build(:user, :password => "password", :password_confirmation => "nope")
        user.should_not be_valid
      end

      it "succeeds if password matches confirmation" do
        user = Factory.build(:user, :password => "password", :password_confirmation => "password")
        user.should be_valid
      end
    end

    describe "of username" do
      it "requires presence" do
        user = Factory.build(:user, :username => nil)
        user.should_not be_valid
      end

      it "requires uniqueness" do
        duplicate_user = Factory.build(:user, :username => alice.username)
        duplicate_user.should_not be_valid
      end

      it "downcases username" do
        user = Factory.build(:user, :username => "WeIrDcAsE")
        user.should be_valid
        user.username.should == "weirdcase"
      end

      it "fails if the requested username is only different in case from an existing username" do
        duplicate_user = Factory.build(:user, :username => alice.username.upcase)
        duplicate_user.should_not be_valid
      end

      it "strips leading and trailing whitespace" do
        user = Factory.build(:user, :username => "    janie    ")
        user.should be_valid
        user.username.should == "janie"
      end

      it "fails if there's whitespace in the middle" do
        user = Factory.build(:user, :username => "bobby tables")
        user.should_not be_valid
      end

      it 'can not contain non url safe characters' do
        user = Factory.build(:user, :username => "kittens;")
        user.should_not be_valid
      end

      it 'should not contain periods' do
        user = Factory.build(:user, :username => "kittens.")
        user.should_not be_valid
      end

      it "can be 32 characters long" do
        user = Factory.build(:user, :username => "hexagoooooooooooooooooooooooooon")
        user.should be_valid
      end

      it "cannot be 33 characters" do
        user = Factory.build(:user, :username => "hexagooooooooooooooooooooooooooon")
        user.should_not be_valid
      end
    end

    describe "of email" do
      it "requires email address" do
        user = Factory.build(:user, :email => nil)
        user.should_not be_valid
      end

      it "requires a unique email address" do
        duplicate_user = Factory.build(:user, :email => alice.email)
        duplicate_user.should_not be_valid
      end
    end

    describe "of language" do
      after do
        I18n.locale = :en
      end
      it "requires availability" do
        user = Factory.build(:user, :language => 'some invalid language')
        user.should_not be_valid
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
  
  describe 'update_user_preferences' do
    it 'unsets disable mail and makes the right amount of prefs' do
      alice.disable_mail = true
      proc {
        alice.update_user_preferences({})
      }.should change(alice.user_preferences, :count).by(6)
    end
    it 'still sets new prefs to false on update' do
      alice.disable_mail = true
      proc {
        alice.update_user_preferences({'mentioned' => false})
      }.should change(alice.user_preferences, :count).by(5)
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

    it "only pushes to non-pending contacts" do
      pending "this test doesn't really test what it says it tests"
      lambda {
        alice.send_contact_request_to(Factory(:user).person, alice.aspects.first)
      }.should change(Contact.unscoped.where(:user_id => alice.id), :count).by(1)

      m = mock()
      m.should_receive(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)
      alice.update_profile(@params).should be_true
    end
    context 'passing in a photo' do
      before do
        fixture_filename  = 'button.png'
        fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture_filename)
        image = File.open(fixture_name)
        @photo = Photo.diaspora_initialize(
                  :author => alice.person, :user_file => image)
        @photo.save!
        @params = {:photo => @photo}
      end
      it 'updates image_url' do
        alice.update_profile(@params).should be_true
        alice.reload.profile.image_url.should == @photo.url(:thumb_large)
        alice.profile.image_url_medium.should == @photo.url(:thumb_medium)
        alice.profile.image_url_small.should == @photo.url(:thumb_small)
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

  context 'aspects' do
    it 'should delete an empty aspect' do
      empty_aspect = alice.aspects.create(:name => 'decoy')
      alice.aspects(true).include?(empty_aspect).should == true
      alice.drop_aspect(empty_aspect)
      alice.aspects(true).include?(empty_aspect).should == false
    end

    it 'should not delete an aspect with contacts' do
      aspect = alice.aspects.first
      aspect.contacts.count.should > 0
      proc { alice.drop_aspect(aspect) }.should raise_error ActiveRecord::StatementInvalid
      alice.aspects.include?(aspect).should == true
    end
  end

  describe '#update_post' do
    it 'sends a notification to aspects' do
      m = mock()
      m.should_receive(:post)
      Postzord::Dispatch.should_receive(:new).and_return(m)
      photo = alice.build_post(:photo, :user_file => uploaded_photo, :caption => "hello", :to => alice.aspects.first.id)
      alice.update_post(photo, :caption => 'hellp')
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

  describe 'account removal' do
    it 'should disconnect everyone' do
      alice.should_receive(:disconnect_everyone)
      alice.destroy
    end

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

    it 'should remove person' do
      alice.should_receive(:remove_person)
      alice.destroy
    end

    it 'should remove all aspects' do
      lambda {
        alice.destroy
      }.should change{ alice.aspects(true).count }.by(-1)
    end

    it 'removes all contacts' do
      lambda {
        alice.destroy
      }.should change { alice.contacts(true).count }.by(-1)
    end

    it 'removes all service connections' do
      Services::Facebook.create(:access_token => 'what', :user_id => alice.id)
      lambda {
        alice.destroy
      }.should change { alice.services(true).count }.by(-1)
    end

    describe '#remove_person' do
      it 'should remove the person object' do
        person = alice.person
        alice.destroy
        person.reload
        person.should be nil
      end

      it 'should remove the posts' do
        message = alice.post(:status_message, :message => "hi", :to => alice.aspects.first.id)
        alice.reload
        alice.destroy
        proc { message.reload }.should raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#disconnect_everyone' do

      it 'has no error on a local friend who has deleted his account' do
        alice.destroy
        lambda {
          bob.destroy
        }.should_not raise_error
      end

      it 'has no error when the user has sent local requests' do
        alice.send_contact_request_to(eve.person, alice.aspects.first)
        lambda {
          alice.destroy
        }.should_not raise_error
      end

      it 'should send retractions to remote poeple' do
        person = eve.person
        eve.delete
        person.owner_id = nil
        person.save
        alice.activate_contact(person, alice.aspects.first)

        alice.should_receive(:disconnect).once
        alice.destroy
      end

      it 'should disconnect local people' do
        lambda {
          alice.destroy
        }.should change{bob.reload.contacts.count}.by(-1)
      end
    end
  end

  describe '#mail' do
    it 'enqueues a mail job' do
      alice.disable_mail = false
      alice.save
      alice.reload

      Resque.should_receive(:enqueue).with(Job::MailRequestReceived, alice.id, 'contactrequestid').once
      alice.mail(Job::MailRequestReceived, alice.id, 'contactrequestid')
    end

    it 'does not enqueue a mail job if the correct corresponding job has a prefrence entry' do
      alice.user_preferences.create(:email_type => 'request_received')
      Resque.should_not_receive(:enqueue)
      alice.mail(Job::MailRequestReceived, alice.id, 'contactrequestid')
    end
  end

end
