# frozen_string_literal: true

describe PostPresenter do
  let(:status_message) { FactoryGirl.create(:status_message, public: true) }
  let(:status_message_with_poll) { FactoryGirl.create(:status_message_with_poll, public: true) }
  let(:presenter) { PostPresenter.new(status_message, bob) }
  let(:unauthenticated_presenter) { PostPresenter.new(status_message) }

  it "takes a post and an optional user" do
    expect(presenter).not_to be_nil
  end

  describe "#as_json" do
    it "works with a user" do
      expect(presenter.as_json).to be_a Hash
    end

    it "works without a user" do
      expect(unauthenticated_presenter.as_json).to be_a Hash
    end
  end

  context "post with interactions" do
    before do
      bob.like!(status_message)
      bob.reshare!(status_message)
    end

    describe "#with_interactions" do
      it "works with a user" do
        post_hash = presenter.with_interactions
        expect(post_hash).to be_a Hash
        expect(post_hash[:interactions]).to eq PostInteractionPresenter.new(status_message, bob).as_json
      end

      it "works without a user" do
        post_hash = unauthenticated_presenter.with_interactions
        expect(post_hash).to be_a Hash
        expect(post_hash[:interactions]).to eq PostInteractionPresenter.new(status_message, nil).as_json
      end
    end

    describe "#with_initial_interactions" do
      it "works with a user" do
        post_hash = presenter.with_initial_interactions
        expect(post_hash).to be_a Hash
        expect(post_hash[:interactions][:likes]).to eq(
          LikeService.new(bob).find_for_post(status_message.id).as_api_response(:backbone)
        )
        expect(post_hash[:interactions][:reshares]).to eq(
          ReshareService.new(bob).find_for_post(status_message.id).as_api_response(:backbone)
        )
      end

      it "works without a user" do
        post_hash = unauthenticated_presenter.with_initial_interactions
        expect(post_hash).to be_a Hash
        expect(post_hash[:interactions][:likes]).to eq(
          LikeService.new.find_for_post(status_message.id).as_api_response(:backbone)
        )
        expect(post_hash[:interactions][:reshares]).to eq(
          ReshareService.new.find_for_post(status_message.id).as_api_response(:backbone)
        )
      end
    end
  end

  describe "#user_like" do
    before do
      bob.like!(status_message)
    end

    it "includes the users like" do
      expect(presenter.send(:user_like)).to be_present
    end

    it "is nil if the user is not authenticated" do
      expect(unauthenticated_presenter.send(:user_like)).to be_nil
    end
  end

  describe "#user_reshare" do
    before do
      bob.reshare!(status_message)
    end

    it "includes the users reshare" do
      expect(presenter.send(:user_reshare)).to be_present
    end

    it "is nil if the user is not authenticated" do
      expect(unauthenticated_presenter.send(:user_reshare)).to be_nil
    end
  end

  describe "#root" do
    it "does not raise if the absolute_root does not exists" do
      first_reshare = FactoryGirl.create :reshare
      first_reshare.root = nil
      reshare = FactoryGirl.create :reshare, root: first_reshare

      expect {
        PostPresenter.new(reshare).send(:root)
      }.to_not raise_error
    end

    it "does not raise if the root does not exists" do
      reshare = FactoryGirl.create :reshare
      reshare.root = nil
      expect {
        PostPresenter.new(reshare).send(:root)
      }.to_not raise_error
    end
  end

  describe "#title" do
    context "with posts with text" do
      it "delegates to message.title" do
        message = double(present?: true)
        expect(message).to receive(:title)
        presenter.post = double(message: message)
        presenter.send(:title)
      end
    end

    context "with posts without text" do
      it "displays a messaage with the post class" do
        sm = double(message: double(present?: false), author: bob.person, author_name: bob.person.name)
        presenter.post = sm
        expect(presenter.send(:title)).to eq("A post from #{sm.author.name}")
      end
    end
  end

  describe "#poll" do
    it "works without a user" do
      presenter = PostPresenter.new(status_message_with_poll)
      expect(presenter.as_json).to be_a(Hash)
    end

    it "returns the answer id of the current user's poll participation" do
      presenter = PostPresenter.new(status_message_with_poll, alice)
      poll_answer = status_message_with_poll.poll.poll_answers.first
      poll_participation = status_message_with_poll.poll.poll_participations
      poll_participation = poll_participation.create(poll_answer: poll_answer, author: alice.person)
      expect(presenter.as_json[:poll_participation_answer_id]).to eql(poll_participation.poll_answer_id)
    end

    it "returns nil if the user did not participate in a poll" do
      presenter = PostPresenter.new(status_message_with_poll, alice)
      expect(presenter.as_json[:poll_participation_answer_id]).to eql(nil)
    end
  end

  describe "#tags" do
    it "returns the tag of the post" do
      post = FactoryGirl.create(:status_message, text: "#hello #world", public: true)

      expect(PostPresenter.new(post).send(:tags)).to match_array(%w(hello world))
    end

    it "returns the tag of the absolute_root of a Reshare" do
      post = FactoryGirl.create(:status_message, text: "#hello #world", public: true)
      first_reshare = FactoryGirl.create(:reshare, root: post)
      second_reshare = FactoryGirl.create(:reshare, root: first_reshare)

      expect(PostPresenter.new(second_reshare).send(:tags)).to match_array(%w(hello world))
    end

    it "does not raise if the root of a reshare does not exist anymore" do
      reshare = FactoryGirl.create(:reshare)
      reshare.root = nil

      expect(PostPresenter.new(reshare).send(:tags)).to eq([])
    end
  end

  describe "#description" do
    it "returns the first 1000 chars of the text" do
      post = FactoryGirl.create(:status_message, text: "a" * 1001, public: true)

      expect(PostPresenter.new(post).send(:description)).to eq("#{'a' * 997}...")
    end

    it "does not change the message if less or equal 1000 chars" do
      post = FactoryGirl.create(:status_message, text: "a" * 1000, public: true)

      expect(PostPresenter.new(post).send(:description)).to eq("a" * 1000)
    end

    it "does not raise if the root of a reshare does not exist anymore" do
      reshare = FactoryGirl.create(:reshare)
      reshare.update(root: nil)

      expect(PostPresenter.new(Post.find(reshare.id)).send(:description)).to eq(nil)
    end
  end

  describe "#build_open_graph_cache" do
    it "returns a dummy og cache if the og cache is missing" do
      expect(presenter.build_open_graph_cache.image).to be_nil
    end

    context "with an open graph cache" do
      it "delegates to as_api_response" do
        og_cache = double("open_graph_cache")
        expect(og_cache).to receive(:as_api_response).with(:backbone)
        presenter.post = double(open_graph_cache: og_cache)
        presenter.send(:build_open_graph_cache)
      end

      it "returns the open graph cache data" do
        open_graph_cache = FactoryGirl.create(:open_graph_cache)
        post = FactoryGirl.create(:status_message, public: true, open_graph_cache: open_graph_cache)
        expect(PostPresenter.new(post).send(:build_open_graph_cache)).to eq(open_graph_cache.as_api_response(:backbone))
      end

      it "returns the open graph data in the api" do
        open_graph_cache = FactoryGirl.create(:open_graph_cache)
        post = FactoryGirl.create(:status_message, public: true, open_graph_cache: open_graph_cache)
        expect(PostPresenter.new(post).as_api_response[:open_graph_object][:url]).to eq(open_graph_cache.url)
      end
    end
  end
end
