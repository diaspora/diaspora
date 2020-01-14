# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe User, :type => :model do
  context "relations" do
    context "#conversations" do
      it "doesn't find anything when there is nothing to find" do
        u = FactoryGirl.create(:user)
        expect(u.conversations).to be_empty
      end

      it "finds the users conversations" do
        c = FactoryGirl.create(:conversation, { author: alice.person })

        expect(alice.conversations).to include c
      end

      it "doesn't find other users conversations" do
        c1 = FactoryGirl.create(:conversation)
        c2 = FactoryGirl.create(:conversation)
        c_own = FactoryGirl.create(:conversation, { author: alice.person })

        expect(alice.conversations).to include c_own
        expect(alice.conversations).not_to include c1
        expect(alice.conversations).not_to include c2
      end
    end
  end

  describe "private key" do
    it 'has a key' do
      expect(alice.encryption_key).not_to be nil
    end

    it 'marshalls the key to and from the db correctly' do
      user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password')

      user.save!
      expect(user.serialized_private_key).to be_present

      expect{
        user.reload.encryption_key
      }.to_not raise_error
    end
  end

  describe 'yearly_actives' do
    it 'returns list which includes users within last year' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 1.month
      user.save
      expect(User.yearly_actives).to include user
    end

    it 'returns list which does not include users seen within last year' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 2.year
      user.save
      expect(User.yearly_actives).not_to include user
    end
  end

  describe 'monthly_actives' do
    it 'returns list which includes users seen within last month' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 1.day
      user.save
      expect(User.monthly_actives).to include user
    end

     it 'returns list which does not include users seen within last month' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 2.month
      user.save
      expect(User.monthly_actives).not_to include user
    end
  end

  describe 'daily_actives' do
    it 'returns list which includes users seen within last day' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 1.hour
      user.save
      expect(User.daily_actives).to include(user)
    end

    it 'returns list which does not include users seen within last day' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 2.day
      user.save
      expect(User.daily_actives).not_to include(user)
    end
  end

  describe 'halfyear_actives' do
    it 'returns list which includes users seen within half a year' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 4.month
      user.save
      expect(User.halfyear_actives).to include user
    end

     it 'returns list which does not include users seen within the last half a year' do
      user = FactoryGirl.build(:user)
      user.last_seen = Time.now - 7.month
      user.save
      expect(User.halfyear_actives).not_to include user
    end
  end

  describe 'hidden_shareables' do
    before do
      @sm = FactoryGirl.create(:status_message)
      @sm_id = @sm.id.to_s
      @sm_class = @sm.class.base_class.to_s
    end

    it 'is a hash' do
      expect(alice.hidden_shareables).to eq({})
    end

    describe '#add_hidden_shareable' do
      it 'adds the share id to an array which is keyed by the objects class' do
        alice.add_hidden_shareable(@sm_class, @sm_id)
        expect(alice.hidden_shareables['Post']).to eq([@sm_id])
      end

      it 'handles having multiple posts' do
        sm2 = FactoryGirl.build(:status_message)
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.add_hidden_shareable(sm2.class.base_class.to_s, sm2.id.to_s)

        expect(alice.hidden_shareables['Post']).to match_array([@sm_id, sm2.id.to_s])
      end

      it 'handles having multiple shareable types' do
        photo = FactoryGirl.create(:photo)
        alice.add_hidden_shareable(photo.class.base_class.to_s, photo.id.to_s)
        alice.add_hidden_shareable(@sm_class, @sm_id)

        expect(alice.hidden_shareables['Photo']).to eq([photo.id.to_s])
      end
    end

    describe '#remove_hidden_shareable' do
      it 'removes the id from the hash if it is there'  do
        alice.add_hidden_shareable(@sm_class, @sm_id)
        alice.remove_hidden_shareable(@sm_class, @sm_id)
        expect(alice.hidden_shareables['Post']).to eq([])
      end
    end

    describe 'toggle_hidden_shareable' do
      it 'calls add_hidden_shareable if the key does not exist, and returns true' do
        expect(alice).to receive(:add_hidden_shareable).with(@sm_class, @sm_id)
        expect(alice.toggle_hidden_shareable(@sm)).to be true
      end

      it 'calls remove_hidden_shareable if the key exists' do
        expect(alice).to receive(:remove_hidden_shareable).with(@sm_class, @sm_id)
        alice.add_hidden_shareable(@sm_class, @sm_id)
        expect(alice.toggle_hidden_shareable(@sm)).to be false
      end
    end

    describe '#is_shareable_hidden?' do
      it 'returns true if the shareable is hidden' do
        post = FactoryGirl.create(:status_message)
        bob.toggle_hidden_shareable(post)
        expect(bob.is_shareable_hidden?(post)).to be true
      end

      it 'returns false if the shareable is not present' do
        post = FactoryGirl.create(:status_message)
        expect(bob.is_shareable_hidden?(post)).to be false
      end
    end
  end


  describe 'overwriting people' do
    it 'does not overwrite old users with factory' do
      expect {
        new_user = FactoryGirl.create(:user, :id => alice.id)
      }.to raise_error ActiveRecord::StatementInvalid
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
      expect(new_user.persisted?).to be true
      expect(new_user.id).not_to eq(alice.id)
    end
  end

  describe "validation" do
    describe "of associated person" do
      it "fails if person is not valid" do
        user = alice
        expect(user).to be_valid

        user.person.serialized_public_key = nil
        expect(user.person).not_to be_valid
        expect(user).not_to be_valid

        expect(user.errors.full_messages.count).to eq(1)
        expect(user.errors.full_messages.first).to match(/Person is invalid/i)
      end
    end

    describe "of username" do
      it "requires presence" do
        alice.username = nil
        expect(alice).not_to be_valid
      end

      it "requires uniqueness" do
        alice.username = eve.username
        expect(alice).not_to be_valid
      end

      it 'requires uniqueness also amount Person objects with diaspora handle' do
        p = FactoryGirl.create(:person, :diaspora_handle => "jimmy#{User.diaspora_id_host}")
        alice.username = 'jimmy'
        expect(alice).not_to be_valid

      end

      it "downcases username" do
        user = FactoryGirl.build(:user, :username => "WeIrDcAsE")
        expect(user).to be_valid
        expect(user.username).to eq("weirdcase")
      end

      it "fails if the requested username is only different in case from an existing username" do
        alice.username = eve.username.upcase
        expect(alice).not_to be_valid
      end

      it "strips leading and trailing whitespace" do
        user = FactoryGirl.build(:user, :username => "      janie   ")
        expect(user).to be_valid
        expect(user.username).to eq("janie")
      end

      it "fails if there's whitespace in the middle" do
        alice.username = "bobby tables"
        expect(alice).not_to be_valid
      end

      it 'can not contain non url safe characters' do
        alice.username = "kittens;"
        expect(alice).not_to be_valid
      end

      it 'should not contain periods' do
        alice.username = "kittens."
        expect(alice).not_to be_valid
      end

      it "can be 32 characters long" do
        alice.username = "hexagoooooooooooooooooooooooooon"
        expect(alice).to be_valid
      end

      it "cannot be 33 characters" do
        alice.username =  "hexagooooooooooooooooooooooooooon"
        expect(alice).not_to be_valid
      end

      it "cannot be one of the blacklist names" do
        ['hostmaster', 'postmaster', 'root', 'webmaster'].each do |username|
          alice.username =  username
          expect(alice).not_to be_valid
        end
      end
    end

    describe "of email" do
      it "requires email address" do
        alice.email = nil
        expect(alice).not_to be_valid
      end

      it "requires a unique email address" do
        alice.email = eve.email
        expect(alice).not_to be_valid
      end

      it "requires a valid email address" do
        alice.email = "somebodyanywhere"
        expect(alice).not_to be_valid
      end

      it "resets a matching unconfirmed_email and confirm_email_token on save" do
        eve.update_attributes(unconfirmed_email: "new@example.com", confirm_email_token: SecureRandom.hex(15))
        alice.update_attribute(:email, "new@example.com")
        eve.reload
        expect(eve.unconfirmed_email).to eql(nil)
        expect(eve.confirm_email_token).to eql(nil)
      end
    end

    describe "of unconfirmed_email" do
      it "unconfirmed_email address can be nil/blank" do
        alice.unconfirmed_email = nil
        expect(alice).to be_valid
        alice.unconfirmed_email = ""
        expect(alice).to be_valid
      end

      it "does NOT require a unique unconfirmed_email address" do
        eve.update_attribute :unconfirmed_email, "new@example.com"
        alice.unconfirmed_email = "new@example.com"
        expect(alice).to be_valid
      end

      it "requires an unconfirmed_email address which is not another user's email address" do
        alice.unconfirmed_email = eve.email
        expect(alice).not_to be_valid
      end

      it "requires a valid unconfirmed_email address" do
        alice.unconfirmed_email = "somebodyanywhere"
        expect(alice).not_to be_valid
      end
    end

    describe "of language" do
      after do
        I18n.locale = :en
      end

      it "requires availability" do
        alice.language = 'some invalid language'
        expect(alice).not_to be_valid
      end

      it "should save with current language if blank" do
        I18n.locale = :fr
        user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password')
        expect(user.language).to eq('fr')
      end

      it "should save with language what is set" do
        I18n.locale = :fr
        user = User.build(:username => 'max', :email => 'foo@bar.com', :password => 'password', :password_confirmation => 'password', :language => 'de')
        expect(user.language).to eq('de')
      end
    end

    describe "of color_theme" do
      it "requires availability" do
        alice.color_theme = "some invalid theme"
        expect(alice).not_to be_valid
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
        expect(@user.persisted?).to be false
        expect(@user.person.persisted?).to be false
        expect(User.find_by_username("ohai")).to be_nil
      end

      it 'saves successfully' do
        expect(@user).to be_valid
        expect(@user.save).to be true
        expect(@user.persisted?).to be true
        expect(@user.person.persisted?).to be true
        expect(User.find_by_username("ohai")).to eq(@user)
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
        expect { User.build(@invalid_params) }.not_to raise_error
      end

      it "does not save" do
        expect(User.build(@invalid_params).save).to be false
      end

      it 'does not save a person' do
        expect { User.build(@invalid_params) }.not_to change(Person, :count)
      end

      it 'does not generate a key' do
        expect(User).to receive(:generate_key).exactly(0).times
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
        expect(User.build(@invalid_params).person.id).not_to eq(person.id)
      end
    end
  end

  describe '#process_invite_acceptence' do
    it 'sets the inviter on user' do
      inv = InvitationCode.create(:user => bob)
      user = FactoryGirl.build(:user)
      user.process_invite_acceptence(inv)
      expect(user.invited_by_id).to eq(bob.id)
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
      expect(alice.reload.disable_mail).to be false
    end
  end

  describe ".find_for_database_authentication" do
    it 'finds a user' do
      expect(User.find_for_database_authentication(:username => alice.username)).to eq(alice)
    end

    it 'finds a user by email' do
      expect(User.find_for_database_authentication(:username => alice.email)).to eq(alice)
    end

    it "does not preserve case" do
      expect(User.find_for_database_authentication(:username => alice.username.upcase)).to eq(alice)
    end
  end

  describe '#update_profile' do
    before do
      @params = {
        :first_name => 'bob',
        :last_name => 'billytown',
      }
    end

    it "dispatches the profile when tags are set" do
      @params = {tag_string: '#what #hey'}
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch).with(alice, alice.profile, {})
      expect(alice.update_profile(@params)).to be true
    end

    it "sends a profile to their contacts" do
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch).with(alice, alice.profile, {})
      expect(alice.update_profile(@params)).to be true
    end

    it 'updates names' do
      expect(alice.update_profile(@params)).to be true
      expect(alice.reload.profile.first_name).to eq('bob')
    end

    it 'updates image_url' do
      params = {:image_url => "http://clown.com"}

      expect(alice.update_profile(params)).to be true
      expect(alice.reload.profile.image_url).to eq("http://clown.com")
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
        expect(alice.update_profile(@params)).to be true
        alice.reload

        expect(alice.profile.image_url).to match(Regexp.new(@photo.url(:thumb_large)))
        expect(alice.profile.image_url_medium).to match(Regexp.new(@photo.url(:thumb_medium)))
        expect(alice.profile.image_url_small).to match(Regexp.new(@photo.url(:thumb_small)))
      end

      it 'unpends the photo' do
        @photo.pending = true
        @photo.save!
        @photo.reload
        expect(alice.update_profile(@params)).to be true
        expect(@photo.reload.pending).to be false
      end
    end
  end

  describe '#update_post' do
    it 'should dispatch post' do
      photo = alice.build_post(:photo, :user_file => uploaded_photo, :text => "hello", :to => alice.aspects.first.id)
      expect(alice).to receive(:dispatch_post).with(photo)
      alice.update_post(photo, :text => 'hellp')
    end
  end

  describe "#destroy" do
    it "raises error" do
      expect {
        alice.destroy
      }.to raise_error "Never destroy users!"
    end
  end

  describe '#mail' do
    it 'enqueues a mail job' do
      alice.disable_mail = false
      alice.save

      expect(Workers::Mail::StartedSharing).to receive(:perform_async).with(alice.id, 'contactrequestid').once
      alice.mail(Workers::Mail::StartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not enqueue a mail job if the correct corresponding job has a preference entry' do
      alice.user_preferences.create(:email_type => 'started_sharing')
      expect(Workers::Mail::StartedSharing).not_to receive(:perform_async)
      alice.mail(Workers::Mail::StartedSharing, alice.id, 'contactrequestid')
    end

    it 'does not send a mail if disable_mail is set to true' do
       alice.disable_mail = true
       alice.save
       alice.reload
       expect(Workers::Mail::StartedSharing).not_to receive(:perform_async)
      alice.mail(Workers::Mail::StartedSharing, alice.id, 'contactrequestid')
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
        expect(alice.like_for(@message)).to eq(@like)
        expect(bob.like_for(@message)).to eq(@like2)
      end

      it "returns nil if there's no like" do
        expect(alice.like_for(@message2)).to be_nil
      end
    end

    describe '#liked?' do
      it "returns true if there's a like" do
        expect(alice.liked?(@message)).to be true
        expect(bob.liked?(@message)).to be true
      end

      it "returns false if there's no like" do
        expect(alice.liked?(@message2)).to be false
      end
    end
  end

  context 'change email' do
    let(:user){ alice }

    describe "#unconfirmed_email" do
      it "is nil by default" do
        expect(user.unconfirmed_email).to eql(nil)
      end

      it "forces blank to nil" do
        user.unconfirmed_email = ""
        user.save!
        expect(user.unconfirmed_email).to eql(nil)
      end

      it "is ignored if it equals email" do
        user.unconfirmed_email = user.email
        user.save!
        expect(user.unconfirmed_email).to eql(nil)
      end

      it "allows change to valid new email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        expect(user.unconfirmed_email).to eql("alice@newmail.com")
      end

      it "downcases the unconfirmed email" do
        user.unconfirmed_email = "AlIce@nEwmaiL.Com"
        user.save!
        expect(user.unconfirmed_email).to eql("alice@newmail.com")
      end
    end

    describe "#confirm_email_token" do
      it "is nil by default" do
        expect(user.confirm_email_token).to eql(nil)
      end

      it "is autofilled when unconfirmed_email is set to new email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        expect(user.confirm_email_token).not_to be_blank
        expect(user.confirm_email_token.size).to eql(30)
      end

      it "is set back to nil when unconfirmed_email is empty" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        expect(user.confirm_email_token).not_to be_blank
        user.unconfirmed_email = nil
        user.save!
        expect(user.confirm_email_token).to eql(nil)
      end

      it "generates new token on every new unconfirmed_email" do
        user.unconfirmed_email = "alice@newmail.com"
        user.save!
        first_token = user.confirm_email_token
        user.unconfirmed_email = "alice@andanotherone.com"
        user.save!
        expect(user.confirm_email_token).not_to eql(first_token)
        expect(user.confirm_email_token.size).to eql(30)
      end
    end

    describe "#send_confirm_email" do
      it "enqueues a mail job on user with unconfirmed email" do
        user.update_attribute(:unconfirmed_email, "alice@newmail.com")
        expect(Workers::Mail::ConfirmEmail).to receive(:perform_async).with(alice.id).once
        alice.send_confirm_email
      end

      it "enqueues NO mail job on user without unconfirmed email" do
        expect(Workers::Mail::ConfirmEmail).not_to receive(:perform_async).with(alice.id)
        alice.send_confirm_email
      end
    end

    describe '#confirm_email' do
      context 'on user with unconfirmed email' do
        before do
          user.update_attribute(:unconfirmed_email, "alice@newmail.com")
        end

        it 'confirms email and set the unconfirmed_email to email on valid token' do
          expect(user.confirm_email(user.confirm_email_token)).to eql(true)
          expect(user.email).to eql("alice@newmail.com")
          expect(user.unconfirmed_email).to eql(nil)
          expect(user.confirm_email_token).to eql(nil)
        end

        it 'returns false and does not change anything on wrong token' do
          expect(user.confirm_email(user.confirm_email_token.reverse)).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).not_to eql(nil)
          expect(user.confirm_email_token).not_to eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          expect(user.confirm_email("")).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).not_to eql(nil)
          expect(user.confirm_email_token).not_to eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          expect(user.confirm_email(nil)).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).not_to eql(nil)
          expect(user.confirm_email_token).not_to eql(nil)
        end
      end

      context 'on user without unconfirmed email' do
        it 'returns false and does not change anything on any token' do
          expect(user.confirm_email("12345"*6)).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).to eql(nil)
          expect(user.confirm_email_token).to eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          expect(user.confirm_email("")).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).to eql(nil)
          expect(user.confirm_email_token).to eql(nil)
        end

        it 'returns false and does not change anything on blank token' do
          expect(user.confirm_email(nil)).to eql(false)
          expect(user.email).not_to eql("alice@newmail.com")
          expect(user.unconfirmed_email).to eql(nil)
          expect(user.confirm_email_token).to eql(nil)
        end
      end
    end
  end


  describe "#retract" do
    let(:retraction) { double }
    let(:post) { FactoryGirl.build(:status_message, author: bob.person, public: true) }

    context "posts" do
      it "sends a retraction" do
        expect(Retraction).to receive(:for).with(post).and_return(retraction)
        expect(retraction).to receive(:defer_dispatch).with(bob)
        expect(retraction).to receive(:perform)

        bob.retract(post)
      end
    end
  end

  describe "#send_reset_password_instructions" do
    it "queues up a job to send the reset password instructions" do
      user = FactoryGirl.create :user
      expect(Workers::ResetPassword).to receive(:perform_async).with(user.id)
      user.send_reset_password_instructions
    end
  end

  describe "#seed_aspects" do
    describe "create aspects" do
      let(:user) {
        user = FactoryGirl.create(:user)
        user.seed_aspects
        user
      }

      [I18n.t('aspects.seed.family'), I18n.t('aspects.seed.friends'),
       I18n.t('aspects.seed.work'), I18n.t('aspects.seed.acquaintances')].each do |aspect_name|
        it "creates an aspect named #{aspect_name} for the user" do
          expect(user.aspects.find_by_name(aspect_name)).not_to be_nil
        end
      end
    end

    describe "autofollow sharing" do
      let(:user) {
        FactoryGirl.create(:user)
      }

      context "with autofollow sharing enabled" do
        it "should start sharing with autofollow account" do
          AppConfig.settings.autofollow_on_join = true
          AppConfig.settings.autofollow_on_join_user = "one"

          expect(Person).to receive(:find_or_fetch_by_identifier).with("one")

          user.seed_aspects
        end
      end

      context "with sharing with diasporahq enabled" do
        it "should not start sharing with the diasporahq account" do
          AppConfig.settings.autofollow_on_join = false

          expect(Person).not_to receive(:find_or_fetch_by_identifier)

          user.seed_aspects
        end
      end
    end
  end

  describe "#send_welcome_message" do
    let(:user) { FactoryGirl.create(:user) }
    let(:podmin) { FactoryGirl.create(:user) }

    context "with welcome message enabled" do
      before do
        AppConfig.settings.welcome_message.enabled = true
      end

      it "should send welcome message from podmin account" do
        AppConfig.admins.account = podmin.username
        expect {
          user.send_welcome_message
        }.to change(user.conversations, :count).by(1)
        expect(user.conversations.first.author.owner.username).to eq podmin.username
      end

      it "should send welcome message text from config" do
        AppConfig.admins.account = podmin.username
        AppConfig.settings.welcome_message.text = "Hello %{username}, welcome!"
        user.send_welcome_message
        expect(user.conversations.first.messages.first.text).to eq "Hello #{user.username}, welcome!"
      end

      it "should use subject from config" do
        AppConfig.settings.welcome_message.subject = "Welcome Message"
        AppConfig.admins.account = podmin.username
        user.send_welcome_message
        expect(user.conversations.first.subject).to eq "Welcome Message"
      end

      it "should send no welcome message if no podmin is specified" do
        AppConfig.admins.account = ""
        user.send_welcome_message
        expect(user.conversations.count).to eq 0
      end

      it "should send no welcome message if podmin is invalid" do
        AppConfig.admins.account = "invalid"
        user.send_welcome_message
        expect(user.conversations.count).to eq 0
      end
    end

    context "with welcome message disabled" do
      it "shouldn't send a welcome message" do
        AppConfig.settings.welcome_message.enabled = false
        AppConfig.admins.account = podmin.username
        user.send_welcome_message
        expect(user.conversations.count).to eq 0
      end
    end
  end

  context "close account" do
    before do
      @user = bob
    end

    describe "#close_account!" do
      it 'locks the user out' do
        @user.close_account!
        expect(@user.reload.access_locked?).to be true
      end

      it 'creates an account deletion' do
        expect{
          @user.close_account!
        }.to change(AccountDeletion, :count).by(1)
      end

      it 'calls person#lock_access!' do
        expect(@user.person).to receive(:lock_access!)
        @user.close_account!
      end
    end

    describe "#clear_account!" do
      it 'resets the password to a random string' do
        random_pass = "12345678909876543210"
        expect(SecureRandom).to receive(:hex).and_return(random_pass)
        @user.clear_account!
        @user.valid_password?(random_pass)
      end

      it 'clears all the clearable fields' do
        @user.reload
        attributes = @user.send(:clearable_fields)
        @user.clear_account!

        @user.reload
        attributes.each do |attr|
          expect(@user.send(attr.to_sym)).to be_blank
        end
      end

      it "disables mail" do
        @user.disable_mail = false
        @user.clear_account!
        expect(@user.reload.disable_mail).to be true
      end

      it "sets getting_started and show_community_spotlight_in_stream and post_default_public fields to false" do
        @user.clear_account!
        expect(@user.reload.getting_started).to be false
        expect(@user.reload.show_community_spotlight_in_stream).to be false
        expect(@user.reload.post_default_public).to be false
      end

      it "removes export archives" do
        @user.perform_export!
        @user.perform_export_photos!
        @user.clear_account!
        @user.reload
        expect(@user.export).not_to be_present
        expect(@user.exported_at).to be_nil
        expect(@user.exported_photos_file).not_to be_present
        expect(@user.exported_photos_at).to be_nil
      end
    end

    describe "#clearable_attributes" do
      it "returns the clearable fields" do
        user = FactoryGirl.create :user
        expect(user.send(:clearable_fields)).to match_array(
          %w(
            language
            reset_password_sent_at
            reset_password_token
            remember_created_at
            sign_in_count
            current_sign_in_at
            last_sign_in_at
            current_sign_in_ip
            hidden_shareables
            last_sign_in_ip
            invited_by_id
            authentication_token
            auto_follow_back
            auto_follow_back_aspect_id
            unconfirmed_email
            confirm_email_token
            last_seen
            color_theme
            post_default_public
            exported_at
            exported_photos_at
            consumed_timestep
            plain_otp_secret
            otp_backup_codes
            otp_required_for_login
            otp_secret
          )
        )
      end
    end
  end

  describe "#export" do
    it "doesn't change the filename when the user is saved" do
      user = FactoryGirl.create(:user)

      filename = user.export.filename
      user.save!

      expect(User.find(user.id).export.filename).to eq(filename)
    end
  end

  describe "queue_export" do
    it "queues up a job to perform the export" do
      user = FactoryGirl.create(:user)
      user.update export: Tempfile.new([user.username, ".json.gz"]), exported_at: Time.zone.now
      expect(Workers::ExportUser).to receive(:perform_async).with(user.id)
      user.queue_export
      expect(user.exporting).to be_truthy
      expect(user.export).not_to be_present
      expect(user.exported_at).to be_nil
    end
  end

  describe "perform_export!" do
    let(:user) { FactoryGirl.create(:user, exporting: true) }

    it "saves a json export to the user" do
      user.perform_export!
      expect(user.export).to be_present
      expect(user.exported_at).to be_present
      expect(user.exporting).to be_falsey
      expect(user.export.filename).to match(/.json/)
      expect(ActiveSupport::Gzip.decompress(user.export.file.read)).to include user.username
    end

    it "compresses the result" do
      expect(ActiveSupport::Gzip).to receive :compress
      user.perform_export!
    end

    it "resets exporting to false when failing" do
      expect_any_instance_of(Diaspora::Exporter).to receive(:execute).and_raise("Unexpected error!")
      user.perform_export!
      expect(user.exporting).to be_falsey
      expect(user.export).not_to be_present
    end
  end

  describe "queue_export_photos" do
    it "queues up a job to perform the export photos" do
      user = FactoryGirl.create(:user)
      user.update exported_photos_file: Tempfile.new([user.username, ".zip"]), exported_photos_at: Time.zone.now
      expect(Workers::ExportPhotos).to receive(:perform_async).with(user.id)
      user.queue_export_photos
      expect(user.exporting_photos).to be_truthy
      expect(user.exported_photos_file).not_to be_present
      expect(user.exported_photos_at).to be_nil
    end
  end

  describe "perform_export_photos!" do
    let(:user) { FactoryGirl.create(:user_with_aspect, exporting: true) }

    before do
      image = File.join(File.dirname(__FILE__), "..", "fixtures", "button.png")
      @saved_image = user.build_post(:photo, user_file: File.open(image), to: user.aspects.first.id)
      @saved_image.save!
    end

    it "saves a zip export to the user" do
      user.perform_export_photos!
      expect(user.exported_photos_file).to be_present
      expect(user.exported_photos_at).to be_present
      expect(user.exporting_photos).to be_falsey
      expect(user.exported_photos_file.filename).to match(/.zip/)
      expect(Zip::File.open(user.exported_photos_file.path).entries.count).to eq(1)
    end

    it "does not add empty entries when photo not found" do
      File.unlink user.photos.first.unprocessed_image.path
      user.perform_export_photos!
      expect(user.exporting_photos).to be_falsey
      expect(user.exported_photos_file.filename).to match(/.zip/)
      expect(Zip::File.open(user.exported_photos_file.path).entries.count).to eq(0)
    end

    it "resets exporting_photos to false when failing" do
      expect_any_instance_of(PhotoExporter).to receive(:perform).and_raise("Unexpected error!")
      user.perform_export_photos!
      expect(user.exporting_photos).to be_falsey
      expect(user.exported_photos_file).not_to be_present
    end
  end

  describe "sign up" do
    before do
      params = {:username => "ohai",
                :email => "ohai@example.com",
                :password => "password",
                :password_confirmation => "password",
                :captcha => "12345",

                :person =>
                  {:profile =>
                    {:first_name => "O",
                     :last_name => "Hai"}
                  }
      }
      @user = User.build(params)
    end

    it "saves with captcha off" do
      AppConfig.settings.captcha.enable = false
      expect(@user).to receive(:save).and_return(true)
      @user.sign_up
    end

    it "saves with captcha on" do
      AppConfig.settings.captcha.enable = true
      expect(@user).to receive(:save_with_captcha).and_return(true)
      @user.sign_up
    end
  end

  describe "maintenance" do
    before do
      @user = bob
      AppConfig.settings.maintenance.remove_old_users.enable = true
    end

    it "#flags user for removal" do
      remove_at = Time.now.change(usec: 0).utc + 5.days
      @user.flag_for_removal(remove_at)
      expect(@user.remove_after).to eq(remove_at)
    end
  end

  describe "#auth database auth maintenance" do
    before do
      @user = bob
      @user.remove_after = Time.now
      @user.save
    end

    it "remove_after is cleared" do
      @user.after_database_authentication
      expect(@user.remove_after).to eq(nil)
    end
  end

  describe "active" do
    before do
      closed_account = FactoryGirl.create(:user)
      closed_account.person.lock_access!
    end

    it "returns total_users excluding closed accounts & users without usernames" do
      expect(User.active.count).to eq 6     # 6 users from fixtures
    end
  end
end
