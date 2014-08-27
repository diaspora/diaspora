require 'spec_helper'

describe EvilQuery::MultiStream do
  let(:evil_query) { EvilQuery::MultiStream.new(alice, 'created_at', Time.now-1.week, true) }
  describe 'community_spotlight_posts!' do
    it 'does not raise an error' do
      expect { evil_query.community_spotlight_posts! }.to_not raise_error
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
    skip
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

      Timecop.return
    end

    let(:posts) {EvilQuery::Participation.new(alice).posts}

    it "doesn't include Posts that aren't acted on" do
      expect(posts.map(&:id)).not_to include(@status_messageD.id)
      expect(posts.map(&:id)).to match_array([@status_messageA.id, @status_messageB.id, @status_messageE.id])
    end

    it "returns the posts that the user has commented on or liked with the most recently acted on ones first" do
      expect(posts.map(&:id)).to eq([@status_messageE.id, @status_messageA.id, @status_messageB.id])
    end
  end
end
