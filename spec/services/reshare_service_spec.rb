# frozen_string_literal: true

describe ReshareService do
  let(:post) { alice.post(:status_message, text: "hello", public: true) }

  describe "#create" do
    it "doesn't create a reshare of my own post" do
      expect {
        ReshareService.new(alice).create(post.id)
      }.to raise_error RuntimeError
    end

    it "creates a reshare of a post of a contact" do
      expect {
        ReshareService.new(bob).create(post.id)
      }.not_to raise_error
    end

    it "attaches the reshare to the post" do
      reshare = ReshareService.new(bob).create(post.id)
      expect(post.reshares.first.id).to eq(reshare.id)
    end

    it "reshares the original post when called with a reshare" do
      reshare = ReshareService.new(bob).create(post.id)
      reshare2 = ReshareService.new(eve).create(reshare.id)
      expect(post.reshares.map(&:id)).to include(reshare2.id)
    end

    it "fails if the post does not exist" do
      expect {
        ReshareService.new(bob).create("unknown id")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "fails if the post is not public" do
      post = alice.post(:status_message, text: "hello", to: alice.aspects.first)

      expect {
        ReshareService.new(bob).create(post.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "fails if the user already reshared the post" do
      ReshareService.new(bob).create(post.id)
      expect {
        ReshareService.new(bob).create(post.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "fails if the user already reshared the original post" do
      reshare = ReshareService.new(bob).create(post.id)
      expect {
        ReshareService.new(bob).create(reshare.id)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "#find_for_post" do
    context "with user" do
      it "returns reshares for a public post" do
        reshare = ReshareService.new(bob).create(post.id)
        expect(ReshareService.new(eve).find_for_post(post.id)).to include(reshare)
      end

      it "returns reshares for a visible private post" do
        post = alice.post(:status_message, text: "hello", to: alice.aspects.first)
        expect(ReshareService.new(bob).find_for_post(post.id)).to be_empty
      end

      it "doesn't return reshares for a private post the user can not see" do
        post = alice.post(:status_message, text: "hello", to: alice.aspects.first)
        expect {
          ReshareService.new(eve).find_for_post(post.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "returns the user's reshare first" do
        [bob, eve].map {|user| ReshareService.new(user).create(post.id) }

        [bob, eve].each do |user|
          expect(
            ReshareService.new(user).find_for_post(post.id).first.author.id
          ).to be user.person.id
        end
      end
    end

    context "without user" do
      it "returns reshares for a public post" do
        reshare = ReshareService.new(bob).create(post.id)
        expect(ReshareService.new.find_for_post(post.id)).to include(reshare)
      end

      it "doesn't return reshares a for private post" do
        post = alice.post(:status_message, text: "hello", to: alice.aspects.first)
        expect {
          ReshareService.new.find_for_post(post.id)
        }.to raise_error Diaspora::NonPublic
      end
    end

    it "returns all reshares of a post" do
      reshares = [bob, eve].map {|user| ReshareService.new(user).create(post.id) }

      expect(ReshareService.new.find_for_post(post.id)).to match_array(reshares)
    end
  end
end
