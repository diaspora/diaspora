require "user"
require "spec_helper"
require "common_expectations"
require "shared_behaviors/account_deletion"
require "shared_behaviors/conversation"

describe "all the possible relationships of a pair of users communication:" do
  metadata[:pod_count] = 2

  before do
    @user1, @user2 = (1..2).map do |i|
      user = User.new(i)
      expect(user.api_client.login("alice", "bluepin7")).to be_truthy
      user
    end
  end

  context "mutual sharing" do
    before do
      @user1.add_to_first_aspect(@user2)
      @user2.add_to_first_aspect(@user1)
      expect_for_sharing_notification(@user1, @user2)
      expect_for_sharing_notification(@user2, @user1)
    end

    it_behaves_like "private and public conversation with a post and comments" do
      let(:aspect) { @user1.api_client.aspects.first["name"] }
    end
    it_behaves_like "user deletion works fine"
  end

  context "a one-way sharing (user1 receiving)" do
    before do
      @user2.add_to_first_aspect(@user1)
      expect_for_sharing_notification(@user1, @user2)
    end

    it_behaves_like "conversation with a post and comments" do
      let(:aspect) { "public" }
    end
    it_behaves_like "user deletion works fine"
  end

  context "a one-way sharing (user1 sharing)" do
    before do
      @user1.add_to_first_aspect(@user2)
      expect_for_sharing_notification(@user2, @user1)
    end

    it_behaves_like "user deletion works fine"
  end

  context "without sharing" do
    context "and without awareness of mutual existence" do
      it_behaves_like "user deletion works fine"
    end

    context "and with prefetched profile" do
      metadata[:upstream] = false
      metadata[:known_federation_bugs] = true

      before do
        # prefetch the profile
        expect(@user2.remote_person(@user1.diaspora_id)).not_to be_nil
      end

      it_behaves_like "user deletion works fine"
    end
  end
end
