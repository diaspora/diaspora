require "spec_helper"

describe PostPresenter do
  before do
    @sm = FactoryGirl.create(:status_message, public: true)
    @sm_with_poll = FactoryGirl.create(:status_message_with_poll, public: true)
    @presenter = PostPresenter.new(@sm, bob)
    @unauthenticated_presenter = PostPresenter.new(@sm)
  end

  it "takes a post and an optional user" do
    expect(@presenter).not_to be_nil
  end

  describe "#as_json" do
    it "works with a user" do
      expect(@presenter.as_json).to be_a Hash
    end

    it "works without a user" do
      expect(@unauthenticated_presenter.as_json).to be_a Hash
    end
  end

  describe "#user_like" do
    it "includes the users like" do
      bob.like!(@sm)
      expect(@presenter.send(:user_like)).to be_present
    end

    it "is nil if the user is not authenticated" do
      expect(@unauthenticated_presenter.send(:user_like)).to be_nil
    end
  end

  describe "#user_reshare" do
    it "includes the users reshare" do
      bob.reshare!(@sm)
      expect(@presenter.send(:user_reshare)).to be_present
    end

    it "is nil if the user is not authenticated" do
      expect(@unauthenticated_presenter.send(:user_reshare)).to be_nil
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
        message = double(present?: true, title: "A title")
        @presenter.post = double(message: message)
        @presenter.send(:title)
        expect(message).to have_received(:title)
      end
    end

    context "with posts without text" do
      it "displays the author name" do
        allow(@sm).to receive(:author).and_return(bob.person)
        allow(@sm).to receive(:message).and_return(double(present?: false))
        expect(@presenter.title).to eq(
          I18n.t("posts.presenter.title", name: bob.person.name)
        )
      end

      context "containing photos" do
        it "displays the author name and photos count" do
          sm_with_photos = FactoryGirl.create(:status_message_with_photo)
          count = sm_with_photos.photos.size
          author = sm_with_photos.author.name
          presenter = PostPresenter.new(sm_with_photos)
          expect(presenter.title).to eq(
            I18n.t("posts.show.photos_by", count: count, author: author)
          )
        end
      end
    end

    context "with reshares" do
      it "displays the resharer name" do
        reshare = FactoryGirl.create(:reshare)
        presenter = PostPresenter.new(reshare)
        expect(presenter.title).to eq(
          I18n.t("posts.show.reshare_by", author: reshare.author_name)
        )
      end
    end
  end

  describe "#poll" do
    it "works without a user" do
      presenter = PostPresenter.new(@sm_with_poll)
      expect(presenter.as_json).to be_a(Hash)
    end
  end
end
