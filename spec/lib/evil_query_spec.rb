# frozen_string_literal: true

describe EvilQuery::MultiStream do
  let(:evil_query) { EvilQuery::MultiStream.new(alice, "created_at", Time.zone.now, true) }

  describe 'community_spotlight_posts!' do
    it 'does not raise an error' do
      expect { evil_query.community_spotlight_posts! }.to_not raise_error
    end
  end

  describe "make_relation!" do
    it "includes public posts of someone you follow" do
      alice.share_with(eve.person, alice.aspects.first)
      public_post = eve.post(:status_message, text: "public post", to: "all", public: true)
      expect(evil_query.make_relation!.map(&:id)).to include(public_post.id)
    end

    it "includes private posts of contacts with a mutual relationship" do
      alice.share_with(eve.person, alice.aspects.first)
      eve.share_with(alice.person, eve.aspects.first)
      private_post = eve.post(:status_message, text: "private post", to: eve.aspects.first.id, public: false)
      expect(evil_query.make_relation!.map(&:id)).to include(private_post.id)
    end

    it "doesn't include posts of followers that you don't follow back" do
      eve.share_with(alice.person, eve.aspects.first)
      public_post = eve.post(:status_message, text: "public post", to: "all", public: true)
      private_post = eve.post(:status_message, text: "private post", to: eve.aspects.first.id, public: false)
      expect(evil_query.make_relation!.map(&:id)).not_to include(public_post.id)
      expect(evil_query.make_relation!.map(&:id)).not_to include(private_post.id)
    end

    it "doesn't include posts with tags from ignored users" do
      tag = ActsAsTaggableOn::Tag.find_or_create_by(name: "test")
      alice.tag_followings.create(tag_id: tag.id)
      alice.blocks.create(person_id: eve.person_id)

      bob_post = bob.post(:status_message, text: "public #test post 1", to: "all", public: true)
      eve_post = eve.post(:status_message, text: "public #test post 2", to: "all", public: true)

      expect(evil_query.make_relation!.map(&:id)).to include(bob_post.id)
      expect(evil_query.make_relation!.map(&:id)).not_to include(eve_post.id)
    end
  end
end

describe EvilQuery::Participation do
  before do
    @status_message = FactoryGirl.create(:status_message, :author => bob.person)
  end

  it "includes posts liked by the user" do
    alice.like!(@status_message)
    expect(EvilQuery::Participation.new(alice).posts).to include(@status_message)
  end

  it "includes posts commented by the user" do
    alice.comment!(@status_message, "hey")
    expect(EvilQuery::Participation.new(alice).posts).to include(@status_message)
  end

  it "should include your statusMessages" do
    expect(EvilQuery::Participation.new(bob).posts).to include(@status_message)
  end

  describe "ordering" do
    before do
      @status_messageA = FactoryGirl.create(:status_message, :author => bob.person)
      @status_messageB = FactoryGirl.create(:status_message, :author => bob.person)
      @status_messageD = FactoryGirl.create(:status_message, :author => bob.person)
      @status_messageE = FactoryGirl.create(:status_message, :author => bob.person)

      time = Time.now

      Timecop.freeze do
        Timecop.travel time += 1.month

        alice.comment!(@status_messageB, "party")
        Timecop.travel time += 1.month

        alice.like!(@status_messageA)
        Timecop.travel time += 1.month

        alice.comment!(@status_messageE, "party")
      end
    end

    let(:posts) {EvilQuery::Participation.new(alice).posts}

    it "doesn't include Posts that aren't acted on" do
      expect(posts.map(&:id)).not_to include(@status_messageD.id)
      expect(posts.map(&:id)).to match_array([@status_messageA.id, @status_messageB.id, @status_messageE.id])
    end

    it "returns the posts that the user has commented on most recently first" do
      expect(posts.map(&:id)).to eq([@status_messageE.id, @status_messageB.id, @status_messageA.id])
    end
  end

  describe "multiple participations" do
    before do
      @like = alice.like!(@status_message)
      @comment = alice.comment!(@status_message, "party")
    end

    let(:posts) { EvilQuery::Participation.new(alice).posts }

    it "includes Posts with multiple participations" do
      expect(posts.map(&:id)).to eq([@status_message.id])
    end

    it "includes Posts with multiple participations only once" do
      eve.like!(@status_message)
      expect(posts.count).to be(1)
    end

    it "includes Posts with multiple participations only once for the post author" do
      eve.like!(@status_message)
      expect(EvilQuery::Participation.new(bob).posts.count).to eq(1)
    end

    it "includes Posts with multiple participation after removing one participation" do
      @like.destroy
      expect(posts.map(&:id)).to eq([@status_message.id])
    end

    it "doesn't includes Posts after removing all of their participations" do
      @like.destroy
      @comment.destroy
      expect(posts.map(&:id)).not_to include(@status_message.id)
    end
  end
end
