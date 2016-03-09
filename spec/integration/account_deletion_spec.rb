describe "deleteing your account", type: :request do
  context "user" do
    before do
      AccountDeleter.new(user.person.diaspora_handle).perform!
      user.reload
    end

    let(:user) { carol }

    it "deletes all of the user's preferences" do
      expect(UserPreference.where(user_id: user.id)).to be_empty
    end

    it "deletes all of the user's notifications" do
      expect(Notification.where(recipient_id: user.id)).to be_empty
    end

    it "deletes all of the users's blocked users" do
      expect(Block.where(user_id: user.id)).to be_empty
    end

    it "deletes all of the user's services" do
      expect(Service.where(user_id: user.id)).to be_empty
    end

    it "deletes all of user's share visiblites" do
      expect(ShareVisibility.where(user_id: user.id)).to be_empty
    end

    it "deletes all aspects" do
      expect(user.aspects).to be_empty
    end

    it "deletes all user contacts" do
      expect(user.contacts).to be_empty
    end

    it "deletes all invitation codes" do
      expect(bob.invitation_codes).to be_empty
    end

    it "deletes all tag followings" do
      expect(bob.tag_followings).to be_empty
    end

    it "clears the account fields" do
      user.send(:clearable_fields).each do |field|
        expect(user.reload[field]).to be_blank
      end
    end

    it_should_behave_like "it removes the person associations" do
      let(:person) { user.person }
    end
  end

  context "remote person" do
    before do
      @person = remote_raphael

      AccountDeleter.new(@person.diaspora_handle).perform!
      @person.reload
    end

    it_should_behave_like "it removes the person associations" do
      let(:person) { @person }
    end
  end
end
