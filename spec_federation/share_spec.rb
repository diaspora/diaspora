require "spec_helper"
require "user"
require "shared_behaviors/adding_to_aspect"
require "shared_behaviors/sharing_posts"

describe "user sharing feature" do
  let(:person_0_on_pod1) { users[1].api_client.find_or_fetch_person(users[0].diaspora_id).first }
  let(:person_1_on_pod0) { users[0].api_client.find_or_fetch_person(users[1].diaspora_id).first }
  let(:users) { [] }

  before do
    (1..2).each do |i|
      user = User.new(i)
      expect(user.register).to be_truthy
      users.push(user)
    end
  end

  it "users are visible across the pods" do
    expect(person_1_on_pod0).not_to be_nil
    expect(person_0_on_pod1).not_to be_nil
  end

  context "in one direction" do
    it_behaves_like "adding to aspect" do
      let(:user0) { users[0] }
      let(:user1) { users[1] }
    end

    it_behaves_like "sharing posts" do
      let(:user0) { users[0] }
      let(:user1) { users[1] }
    end
  end

  context "in opposite direction" do
    it_behaves_like "adding to aspect" do
      let(:user0) { users[1] }
      let(:user1) { users[0] }
    end

    it_behaves_like "sharing posts" do
      let(:user0) { users[1] }
      let(:user1) { users[0] }
    end
  end
end
