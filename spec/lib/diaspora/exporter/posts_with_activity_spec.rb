describe Diaspora::Exporter::PostsWithActivity do
  let(:user) { FactoryGirl.create(:user) }
  let(:instance) { Diaspora::Exporter::PostsWithActivity.new(user) }

  describe "#query" do
    let(:activity) {
      [
        user.person.likes.first.target,
        user.person.comments.first.parent,
        user.person.poll_participations.first.parent.status_message,
        user.person.participations.first.target,
        user.person.posts.reshares.first.root
      ]
    }

    before do
      DataGenerator.create(user, %i[activity participation])
    end

    it "returns all posts with person's activity" do
      expect(instance.query).to match_array(activity)
    end
  end
end
