# frozen_string_literal: true

describe Export::OwnPostSerializer do
  let(:author) { FactoryGirl.create(:user_with_aspect).person }

  before do
    author.owner.share_with(FactoryGirl.create(:person), author.owner.aspects.first)
  end

  it_behaves_like "a federation entity serializer" do
    let(:object) { create(:status_message_with_photo, author: author) }
  end

  let(:json) { Export::OwnPostSerializer.new(post, root: false).to_json }

  context "with private post" do
    let(:post) { create(:status_message_in_aspect, author: author) }

    it "includes remote people subscriptions" do
      expect(JSON.parse(json)["subscribed_users_ids"]).not_to be_empty
      expect(json).to include_json(subscribed_users_ids: post.subscribers.map(&:diaspora_handle))
    end

    it "doesn't include remote pods subscriptions" do
      expect(JSON.parse(json)).not_to have_key("subscribed_pods_uris")
    end
  end

  context "with public post" do
    let(:post) {
      FactoryGirl.create(
        :status_message_with_participations,
        author:       author,
        participants: Array.new(2) { FactoryGirl.create(:person) },
        public:       true
      )
    }

    it "includes pods subscriptions" do
      expect(JSON.parse(json)["subscribed_pods_uris"]).not_to be_empty
      expect(json).to include_json(
        subscribed_pods_uris: post.subscribed_pods_uris.push(AppConfig.pod_uri.to_s)
      )
    end

    it "doesn't include remote people subscriptions" do
      expect(JSON.parse(json)).not_to have_key("subscribed_users_ids")
    end
  end
end
