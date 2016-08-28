require "user"
require "spec_helper"
require "shared_behaviors/conversation"

describe "three users communication testsuite" do
  metadata[:pod_count] = 3

  before do
    @user1, @user2, @user3 = (1..3).map do |i|
      user = User.new(i)
      expect(user.api_client.login("alice", "bluepin7")).to be_truthy
      user
    end
  end

  it_behaves_like "private and public 3 users conversation with a post and comments" do
    let(:aspect) { @user2.api_client.aspects.first["name"] }
  end
end
