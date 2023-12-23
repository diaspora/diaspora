# frozen_string_literal: true

describe Admin::UsersController, :type => :controller do
  before do
    @user = FactoryBot.create :user
    Role.add_admin(@user.person)

    sign_in @user, scope: :user
  end

  describe "#close_account" do
    it "queues a job to disable the given account" do
      other_user = FactoryBot.create :user
      msg = other_user.post(:status_message, text: "Should be kept", public: true)

      # It's possible to close a persons account that do not have a local user
      expect(Workers::WipeAccount).not_to receive(:perform_async)
      post :close_account, params: {id: other_user.person.id}
      other_user.reload
      expect(other_user.access_locked?).to be true
      # it should keep posts
      expect(Post.exists?(msg.id)).to be true
    end
  end

  describe "#wipe_and_close_account" do
    it "closes an account and request to wipe data" do
      other_user = FactoryBot.create :user
      expect(Workers::WipeAccount).to receive(:perform_async)
      post :wipe_and_close_account, params: {id: other_user.person.id}
      other_user.reload
      expect(other_user.closed_account?).to be true
    end
  end

  describe "#lock_access" do
    it "it locks the given account" do
      other_user = FactoryBot.create :user
      other_user.lock_access!
      other_user.reload
      expect(other_user.access_locked?).to be_truthy
    end
  end

  describe "#unlock_access" do
    it "it unlocks the given account" do
      other_user = FactoryBot.create :user
      other_user.lock_access!
      other_user.unlock_access!
      expect(other_user.reload.access_locked?).to be_falsey
    end
  end

end
