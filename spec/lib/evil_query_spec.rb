require 'spec_helper'

describe EvilQuery::Participation do
  before do
    @status_message = Factory(:status_message, :author => bob.person)
  end

  it "includes posts liked by the user" do
    alice.like!(@status_message)
    EvilQuery::Participation.new(alice).posts.should include(@status_message)
  end

  it "includes posts commented by the user" do
    alice.comment!(@status_message, "hey")
    EvilQuery::Participation.new(alice).posts.should include(@status_message)
  end

  it "should include your statusMessages" do
    pending
  end

  describe "ordering" do
    before do
      @status_messageA = Factory(:status_message, :author => bob.person)
      @status_messageB = Factory(:status_message, :author => bob.person)
      @photoC = Factory(:activity_streams_photo, :author => bob.person)
      @status_messageD = Factory(:status_message, :author => bob.person)
      @status_messageE = Factory(:status_message, :author => bob.person)

      time = Time.now

      Timecop.freeze do
        Timecop.travel time += 1.month

        alice.comment!(@status_messageB, "party")
        Timecop.travel time += 1.month

        alice.like!(@status_messageA)
        Timecop.travel time += 1.month

        alice.comment!(@photoC, "party")
        Timecop.travel time += 1.month

        alice.comment!(@status_messageE, "party")
      end

      Timecop.return
    end

    let(:posts) {EvilQuery::Participation.new(alice).posts}

    it "doesn't include Posts that aren't acted on" do
      posts.map(&:id).should_not include(@status_messageD.id)
      posts.map(&:id).should =~ [@status_messageA.id, @status_messageB.id, @photoC.id, @status_messageE.id]
    end

    it "returns the posts that the user has commented on or liked with the most recently acted on ones first" do
      posts.map(&:id).should == [@status_messageE.id, @photoC.id, @status_messageA.id, @status_messageB.id]
    end
  end

  describe "posts with the same timestamp" do
    before do
      @status_msgZ = Factory(:status_message, :author => bob.person)
      @status_msgY = Factory(:status_message, :author => bob.person)
      @status_msgX = Factory(:activity_streams_photo, :author => bob.person)

      Timecop.freeze do
        alice.like!(@status_msgY)
        alice.comment!(@status_msgZ, "party")
        alice.like!(@status_msgX)
      end
    end

    let(:posts) {EvilQuery::Participation.new(alice).posts}

    it "returns the posts in the reverse order they were interacted with" do
      posts.map(&:id).should == [@status_msgX.id, @status_msgZ.id, @status_msgY.id]
    end
  end

end
