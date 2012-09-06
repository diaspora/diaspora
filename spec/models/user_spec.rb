#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  describe "private key" do
    it 'has a key' do
      alice.encryption_key.should_not be nil
    end

    it 'marshalls the key to and from the db correctly' do
      user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password')

      user.save!
      user.serialized_private_key.should be_present

      expect{
        user.reload.encryption_key
      }.to_not raise_error
    end
  end

  context 'callbacks' do
    describe '#save_person!' do
      it 'saves the corresponding user if it has changed' do
        alice.person.url = "http://stuff.com"
        Person.any_instance.should_receive(:save)
        alice.save
      end

      it 'does not save the corresponding user if it has not changed' do
        Person.any_instance.should_not_receive(:save)
        alice.save
      end
    end
  end

  describe 'hidden_shareables' do
    before do
      @sm = FactoryGirl.create(:status_message)
      @sm_id = @sm.id.to_s
      @sm_class = @sm.class.base_class.to_s
    end

    it 'is a hash' do
      alice.hidden_shareables.should == {}
    end

    describe '#add_hidden_shareable' do
      it 'adds the share id to an array which is keyed by the objects class' do
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.hidden_shareables['Post'].should == [@sm_id]
      end

      it 'handles having multiple posts' do
        sm2 = FactoryGirl.build(:status_message)
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.add_hidden_shareable(sm2.class.base_class.to_s, sm2.id.to_s)

        alice.hidden_shareables['Post'].should =~ [@sm_id, sm2.id.to_s]
      end

      it 'handles having multiple shareable types' do
        photo = FactoryGirl.create(:photo)
        alice.add_hidden_shareable(photo.class.base_class.to_s, photo.id.to_s)
        alice.add_hidden_shareable(@sm_class, @sm_id)

        alice.hidden_shareables['Photo'].should == [photo.id.to_s]
      end
    end

    describe '#remove_hidden_shareable' do
      it 'removes the id from the hash if it is there'  do
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.remove_hidden_shareable(@sm_class, @sm_id)
        alice.hidden_shareables['Post'].should == []
      end
    end

    describe 'toggle_hidden_shareable' do
      it 'calls add_hidden_shareable if the key does not exist, and returns true' do
        alice.should_receive(:add_hidden_shareable).with(@sm_class, @sm_id)
        alice.toggle_hidden_shareable(@sm).should be_true
      end

      it 'calls remove_hidden_shareable if the key exists' do
        alice.should_receive(:remove_hidden_shareable).with(@sm_class, @sm_id)
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.toggle_hidden_shareable(@sm).should be_false
      end
    end

    describe '#is_shareable_hidden?' do
      it 'returns true if the shareable is hidden' do
        post = FactoryGirl.create(:status_message)
        bob.toggle_hidden_shareable(post)
        bob.is_shareable_hidden?(post).should be_true
      end

      it 'returns false if the shareable is not present' do
        post = FactoryGirl.create(:status_message)
        bob.is_shareable_hidden?(post).should be_false
      end
    end
  end


  describe 'overwriting people' do
    it 'does not overwrite old users with factory' do
      lambda {
        new_user = FactoryGirl.create(:user, :id => alice.id)
      }.should raise_error ActiveRecord::StatementInvalid
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

      it 'requires uniqueness also amount Person objects with diaspora handle' do
        p = FactoryGirl.create(:person, :diaspora_handle => "jimmy#{User.diaspora_id_host}")
        alice.username = 'jimmy'
        alice.should_not be_valid

      end

      it "downcases username" do
        user = FactoryGirl.build(:user, :username => "WeIrDcAsE")
        user.should be_valid
        user.username.should == "weirdcase"
      end

      it "fails if the requested username is only different in case from an existing username" do
        alice.username = eve.username.upcase
        alice.should_not be_valid
      end

      it "strips leading and trailing whitespace" do
        user = FactoryGirl.build(:user, :username => "      janie   ")
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

      it "cannot be one of the blacklist names" do
        ['hostmaster', 'postmaster', 'root', 'webmaster'].each do |username|
          alice.username =  username
          alice.should_not be_valid
        end
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

      it "requires a vaild email address" do
        alice.email = "somebody@anywhere"
        alice.should_not be_valid
      end
    end

    describe "of unconfirmed_email" do
      it "unconfirmed_email address can be nil/blank" do
        alice.unconfirmed_email = nil
        alice.should be_valid
        alice.unconfirmed_email = ""
        alice.should be_valid
      end

      it "does NOT require a unique unconfirmed_email address" do
        eve.update_attribute :unconfirmed_email, "new@email.com"
        alice.unconfirmed_email = "new@email.com"
        alice.should be_valid
      end

      it "requires a vaild unconfirmed_email address" do
        alice.unconfirmed_email = "somebody@anywhere"
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
        user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password')
        user.language.should == 'fr'
      end

      it "should save with language what is set" do
        I18n.locale = :fr
        user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password', :language => 'de')
        user.language.should == 'de'
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
      let(:person) {FactoryGirl.create :person}
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


  describe '#process_invite_acceptence' do
    it 'sets the inviter on user' do
      inv = InvitationCode.create(:user => bob)
      user = FactoryGirl.build(:user)
      user.process_invite_acceptence(inv)
      user.invited_by_id.should == bob.id
    end
  end

  describe 'update_user_preferences' do
    before do
      @pref_count = UserPreference::VALID_EMAIL_TYPES.count
    end

    it 'unsets disable mail and makes the right amount of prefs' do
      alice.disable_mail = true
      expect {
        alice.update_user_preferences({})
      }.to change(alice.user_preferences, :count).by(@pref_count)
    end

    it 'still sets new prefs to false on update' do
      alice.disable_mail = true
      expect {
        alice.update_user_preferences({'mentioned' => false})
      }.to change(alice.user_preferences, :count).by(@pref_count-1)
      alice.reload.disable_mail.should be_false
    end
  end

  describe ".find_for_database_authentication" do
    it 'finds a user' do
      User.find_for_database_authentication(:username => alice.username).should == alice
    end

    it 'finds a user by email' do
      User.find_for_database_authentication(:username => alice.email).should == alice
    end

    it "does not preserve case" do
      User.find_for_database_authentication(:username => alice.username.upcase).should == alice
    end

    it 'errors out when passed a non-hash' do
      lambda {
        User.find_for_database_authentication(alice.username)
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
      mailman = Postzord::Dispatcher.build(alice, Profile.new)
      Postzord::Dispatcher.should_receive(:build).and_return(mailman)
      alice.update_profile(@params).should be_true
    end

    it 'sends a profile to their contacts' do
      mailman = Postzord::Dispatcher.build(alice, Profile.new)
      Postzord::Dispatcher.should_receive(:build).and_return(mailman)
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
    it 'should dispatch post' do
      photo = alice.build_post(:photo, :user_file => uploaded_photo, :text => "hello", :to => alice.aspects.first.id)
      alice.should_receive(:dispatch_post).with(photo)
      alice.update_post(photo, :text => 'hellp')
    end
  end

  describe '#notify_if_mentioned' do
    before do
      @post = FactoryGirl.build(:status_message, :author => bob.person)
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
      @post = FactoryGirl.build(:status_message, :author => eve.person)
      @post.stub(:mentions?).and_return(true)
      @post.should_not_receive(:notify_person)

      alice.notify_if_mentioned(@post)
    end
  end

  describe 'account deletion' do
    describe '#destroy' do
      it 'removes invitations from the user' do
        FactoryGirl.create(:invitation, :sender => alice)
        lambda {
          alice.destroy
        }.should change {alice.invitations_from_me(true).count }.by(-1)
      end

      it 'removes invitations to the user' do
        Invitation.new(:sender => eve, :recipient => alice, :identifier => alice.email, :aspect => eve.aspects.first).save(:validate => false)
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
  end

  describe '#mail' do
    it 'enqueues a mail job' do
      alice.disable_mail = false
      alice.save

      Resque.should_receive(:enqueue).with(Jobs::Mail::StartedSharing, alice.id, 'contactrequestid').once
      alice.mail(Jobs::Mail::StartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not enqueue a mail job if the correct corresponding job has a prefrence entry' do
      alice.user_preferences.create(:email_type => 'started_sharing')
      Resque.should_not_receive(:enqueue)
      alice.mail(Jobs::Mail::StartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not send a mail if disable_mail is set to true' do
       alice.disable_mail = true
       alice.save
       alice.reload
       Resque.should_not_receive(:enqueue)
      alice.mail(Jobs::Mail::StartedSharing, alice.id, 'contactrequestid')
    end
  end

  context "aspect management" do
    before do
      @contact = alice.contact_for(bob.person)
      @original_aspect = alice.aspects.where(:name => "generic").first
      @new_aspect = alice.aspects.create(:name => 'two')
    end

    describe "#add_contact_to_aspect" do
      it 'adds the contact to the aspect' do
        lambda {
          alice.add_contact_to_aspect(@contact, @new_aspect)
        }.should change(@new_aspect.contacts, :count).by(1)
      end

      it 'returns true if they are already in the aspect' do
        alice.add_contact_to_aspect(@contact, @original_aspect).should be_true
      end
    end
  end

  context 'likes' do
    before do
      alices_aspect = alice.aspects.where(:name => "generic").first
      @bobs_aspect = bob.aspects.where(:name => "generic").first
      @message = alice.post(:status_message, :text => "cool", :to => alices_aspect)
      @message2 = bob.post(:status_message, :text => "uncool", :to => @bobs_aspect)
      @like = alice.like!(@message)
      @like2 = bob.like!(@message)
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

  context 'change email' do
    let(:user){ alice }

    describe "#unconfirmed_email" do
      it "is nil by default" do
        user.unconfirmed_email.should eql(nil)
      end

      it "forces blank to nil" do
        user.unconfirmed_email = ""
        user.save!
        user.unconfirmed_email.should eql(nil)
      end

      it "is ignored if it equals email" do
        user.unconfirmed_email = user.email
        user.save!
        user.unconfirmed_email.should eql(nil)
      end

      it "allows change to valid new email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        user.unconfirmed_email.should eql("alice@newmail.com")
      end
    end

    describe "#confirm_email_token" do
      it "is nil by default" do
        user.confirm_email_token.should eql(nil)
      end

      it "is autofilled when unconfirmed_email is set to new email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        user.confirm_email_token.should_not be_blank
        user.confirm_email_token.size.should eql(30)
      end

      it "is set back to nil when unconfirmed_email is empty" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        user.confirm_email_token.should_not be_blank
        user.unconfirmed_email = nil
        user.save!
        user.confirm_email_token.should eql(nil)
      end

      it "generates new token on every new unconfirmed_email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        first_token = user.confirm_email_token
        user.unconfirmed_email = "alice@andanotherone.com"
        user.save!
        user.confirm_email_token.should_not eql(first_token)
        user.confirm_email_token.size.should eql(30)
      end
    end

    describe '#mail_confirm_email' do
      it 'enqueues a mail job on user with unconfirmed email' do
        user.update_attribute(:unconfirmed_email, "alice@newmail.com")
        Resque.should_receive(:enqueue).with(Jobs::Mail::ConfirmEmail, alice.id).once
        alice.mail_confirm_email.should eql(true)
      end

      it 'enqueues NO mail job on user without unconfirmed email' do
        Resque.should_not_receive(:enqueue).with(Jobs::Mail::ConfirmEmail, alice.id)
        alice.mail_confirm_email.should eql(false)
      end
    end

    describe '#confirm_email' do
      context 'on user with unconfirmed email' do
        before do
          user.update_attribute(:unconfirmed_email, "alice@newmail.com")
        end

        it 'confirms email and set the unconfirmed_email to email on valid token' do
          user.confirm_email(user.confirm_email_token).should eql(true)
          user.email.should eql("alice@newmail.com")
          user.unconfirmed_email.should eql(nil)
          user.confirm_email_token.should eql(nil)
        end

        it 'returns false and does not change anything on wrong token' do
          user.confirm_email(user.confirm_email_token.reverse).should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should_not eql(nil)
          user.confirm_email_token.should_not eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          user.confirm_email("").should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should_not eql(nil)
          user.confirm_email_token.should_not eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          user.confirm_email(nil).should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should_not eql(nil)
          user.confirm_email_token.should_not eql(nil)
        end
      end

      context 'on user without unconfirmed email' do
        it 'returns false and does not change anything on any token' do
          user.confirm_email("12345"*6).should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should eql(nil)
          user.confirm_email_token.should eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          user.confirm_email("").should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should eql(nil)
          user.confirm_email_token.should eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          user.confirm_email(nil).should eql(false)
          user.email.should_not eql("alice@newmail.com")
          user.unconfirmed_email.should eql(nil)
          user.confirm_email_token.should eql(nil)
        end
      end
    end
  end


  describe '#retract' do
    before do
      @retraction = mock
      @post = FactoryGirl.build(:status_message, :author => bob.person, :public => true)
    end

    context "posts" do
      before do
        SignedRetraction.stub(:build).and_return(@retraction)
        @retraction.stub(:perform)
      end

      it 'sends a retraction' do
        dispatcher = mock
        Postzord::Dispatcher.should_receive(:build).with(bob, @retraction, anything()).and_return(dispatcher)
        dispatcher.should_receive(:post)

        bob.retract(@post)
      end

      it 'adds resharers of target post as additional subsctibers' do
        person = FactoryGirl.create(:person)
        reshare = FactoryGirl.create(:reshare, :root => @post, :author => person)
        @post.reshares << reshare

        dispatcher = mock
        Postzord::Dispatcher.should_receive(:build).with(bob, @retraction, {:additional_subscribers => [person]}).and_return(dispatcher)
        dispatcher.should_receive(:post)

        bob.retract(@post)
      end
    end
  end

  describe "#send_reset_password_instructions" do
    it "generates a reset password token if it's supposed to" do
      user = User.new
      user.stub!(:should_generate_token?).and_return(true)
      user.should_receive(:generate_reset_password_token)
      user.send_reset_password_instructions
    end

    it "does not generate a reset password token if it's not supposed to" do
      user = User.new
      user.stub!(:should_generate_token?).and_return(false)
      user.should_not_receive(:generate_reset_password_token)
      user.send_reset_password_instructions
    end

    it "queues up a job to send the reset password instructions" do
      user = FactoryGirl.create :user
      Resque.should_receive(:enqueue).with(Jobs::ResetPassword, user.id)
      user.send_reset_password_instructions
    end
  end

  context "close account" do
    before do
      @user = bob
    end

    describe "#close_account!" do
      it 'locks the user out' do
        @user.close_account!
        @user.reload.access_locked?.should be_true
      end

      it 'creates an account deletion' do
        expect{
          @user.close_account!
        }.to change(AccountDeletion, :count).by(1)
      end

      it 'calls person#lock_access!' do
        @user.person.should_receive(:lock_access!)
        @user.close_account!
      end
    end

    describe "#clear_account!" do
      it 'resets the password to a random string' do
        random_pass = "12345678909876543210"
        SecureRandom.should_receive(:hex).and_return(random_pass)
        @user.clear_account!
        @user.valid_password?(random_pass)
      end

      it 'clears all the clearable fields' do
        @user.reload
        attributes = @user.send(:clearable_fields)
        @user.clear_account!

        @user.reload
        attributes.each do |attr|
          @user.send(attr.to_sym).should be_blank
        end
      end
    end

    describe "#clearable_attributes" do
      it 'returns the clearable fields' do
        user = FactoryGirl.create :user
        user.send(:clearable_fields).sort.should == %w{
          language
          invitation_token
          invitation_sent_at
          reset_password_token
          remember_token
          remember_created_at
          sign_in_count
          current_sign_in_at
          last_sign_in_at
          current_sign_in_ip
          hidden_shareables
          last_sign_in_ip
          invitation_service
          invitation_identifier
          invitation_limit
          invited_by_id
          invited_by_type
          authentication_token
          auto_follow_back
          auto_follow_back_aspect_id
          unconfirmed_email
          confirm_email_token
        }.sort
      end
    end
  end
end
