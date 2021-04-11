# frozen_string_literal: true

describe Reshare, type: :model do
  it "has a valid Factory" do
    expect(FactoryBot.build(:reshare)).to be_valid
  end

  context "validation" do
    it "requires root when the author is local" do
      reshare = FactoryBot.build(:reshare, root: nil, author: alice.person)
      expect(reshare).not_to be_valid
    end

    it "doesn't require root when the author is remote" do
      reshare = FactoryBot.build(:reshare, root: nil, author: remote_raphael)
      expect(reshare).to be_valid
    end

    it "require public root" do
      reshare = FactoryBot.build(:reshare, root: FactoryBot.create(:status_message, public: false))
      expect(reshare).not_to be_valid
      expect(reshare.errors[:base]).to include("Only posts which are public may be reshared.")
    end

    it "allows two reshares without a root" do
      reshare1 = FactoryBot.create(:reshare, author: alice.person)
      reshare2 = FactoryBot.create(:reshare, author: alice.person)

      reshare1.update(root_guid: nil)

      reshare2.root_guid = nil
      expect(reshare2).to be_valid
    end

    it "doesn't allow to reshare the same post twice" do
      post = FactoryBot.create(:status_message, public: true)
      FactoryBot.create(:reshare, author: alice.person, root: post)

      expect(FactoryBot.build(:reshare, author: alice.person, root: post)).not_to be_valid
    end

    it "allows to reshare the same post with different people" do
      post = FactoryBot.create(:status_message, public: true)
      FactoryBot.create(:reshare, author: alice.person, root: post)

      expect(FactoryBot.build(:reshare, author: bob.person, root: post)).to be_valid
    end
  end

  it "forces public" do
    expect(FactoryBot.create(:reshare, public: false).public).to be true
  end

  describe "#root_diaspora_id" do
    let(:reshare) { create(:reshare, root: FactoryBot.build(:status_message, author: bob.person, public: true)) }

    it "should return the root diaspora id" do
      expect(reshare.root_diaspora_id).to eq(bob.person.diaspora_handle)
    end

    it "should be nil if no root found" do
      reshare.root = nil
      expect(reshare.root_diaspora_id).to be_nil
    end
  end

  describe "#receive" do
    let(:reshare) { create(:reshare, root: FactoryBot.build(:status_message, author: bob.person, public: true)) }

    it "participates root author in the reshare" do
      reshare.receive([])
      expect(Participation.where(target_id: reshare.id, author_id: bob.person.id).count).to eq(1)
    end
  end

  describe "#nsfw" do
    let(:sfw) { build(:status_message, author: alice.person, public: true) }
    let(:nsfw) { build(:status_message, author: alice.person, public: true, text: "This is #nsfw") }
    let(:sfw_reshare) { build(:reshare, root: sfw) }
    let(:nsfw_reshare) { build(:reshare, root: nsfw) }

    it "deletates #nsfw to the root post" do
      expect(sfw_reshare.nsfw).not_to be true
      expect(nsfw_reshare.nsfw).to be_truthy
    end
  end

  describe "#poll" do
    let(:root_post) { create(:status_message_with_poll, public: true) }
    let(:reshare) { create(:reshare, root: root_post) }

    it "contains root poll" do
      expect(reshare.poll).to eq root_post.poll
    end
  end

  describe "#absolute_root" do
    before do
      @status_message = FactoryBot.build(:status_message, author: alice.person, public: true)
      reshare1 = FactoryBot.build(:reshare, root: @status_message)
      reshare2 = FactoryBot.build(:reshare, root: reshare1)
      @reshare3 = FactoryBot.build(:reshare, root: reshare2)

      status_message = FactoryBot.create(:status_message, author: alice.person, public: true)
      reshare1 = FactoryBot.create(:reshare, root: status_message)
      @of_deleted = FactoryBot.build(:reshare, root: reshare1)
      status_message.destroy
      reshare1.reload
    end

    it "resolves root posts to the top level" do
      expect(@reshare3.absolute_root).to eq(@status_message)
    end

    it "can handle deleted reshares" do
      expect(@of_deleted.absolute_root).to be_nil
    end

    it "is used everywhere" do
      expect(@reshare3.message).to eq @status_message.message
      expect(@of_deleted.message).to be_nil
      expect(@reshare3.photos).to eq @status_message.photos
      expect(@of_deleted.photos).to be_empty
      expect(@reshare3.o_embed_cache).to eq @status_message.o_embed_cache
      expect(@of_deleted.o_embed_cache).to be_nil
      expect(@reshare3.open_graph_cache).to eq @status_message.open_graph_cache
      expect(@of_deleted.open_graph_cache).to be_nil
      expect(@reshare3.mentioned_people).to eq @status_message.mentioned_people
      expect(@of_deleted.mentioned_people).to be_empty
      expect(@reshare3.nsfw).to eq @status_message.nsfw
      expect(@of_deleted.nsfw).to be_nil
      expect(@reshare3.address).to eq @status_message.location.try(:address)
      expect(@of_deleted.address).to be_nil
    end
  end

  describe "#post_location" do
    let(:status_message) { build(:status_message, text: "This is a status_message", author: bob.person, public: true) }
    let(:reshare) { create(:reshare, root: status_message) }

    context "with location" do
      let(:location) { build(:location) }

      it "should deliver address and coordinates" do
        status_message.location = location
        expect(reshare.post_location).to include(address: location.address, lat: location.lat, lng: location.lng)
      end
    end

    context "without location" do
      it "should deliver empty address and coordinates" do
        expect(reshare.post_location[:address]).to be_nil
        expect(reshare.post_location[:lat]).to be_nil
        expect(reshare.post_location[:lng]).to be_nil
      end
    end
  end

  describe "#subscribers" do
    it "adds root author to subscribers" do
      user = FactoryBot.create(:user_with_aspect)
      user.share_with(alice.person, user.aspects.first)

      post = eve.post(:status_message, text: "hello", public: true)
      reshare = FactoryBot.create(:reshare, root: post, author: user.person)

      expect(reshare.subscribers).to match_array([alice.person, eve.person, user.person])
    end

    it "does not add the root author if the root post was deleted" do
      user = FactoryBot.create(:user_with_aspect)
      user.share_with(alice.person, user.aspects.first)

      post = eve.post(:status_message, text: "hello", public: true)
      reshare = FactoryBot.create(:reshare, root: post, author: user.person)
      post.destroy

      expect(reshare.reload.subscribers).to match_array([alice.person, user.person])
    end
  end
end
