require "spec_helper"

describe User::SocialActions, :type => :model do
  before do
    @bobs_aspect = bob.aspects.where(:name => "generic").first
    @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
  end

  describe 'User#comment!' do
    it "sets the comment text" do
      expect(alice.comment!(@status, "unicorn_mountain").text).to eq("unicorn_mountain")
    end

    it "creates a partcipation" do
      expect{ alice.comment!(@status, "bro") }.to change(Participation, :count).by(1)
      expect(alice.participations.last.target).to eq(@status)
    end

    it "creates the comment" do
      expect{ alice.comment!(@status, "bro") }.to change(Comment, :count).by(1)
    end

    it "federates" do
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Postzord::Dispatcher).to receive(:defer_build_and_post)
      alice.comment!(@status, "omg")
    end
  end

  describe 'User#like!' do
    it "creates a partcipation" do
      expect{ alice.like!(@status) }.to change(Participation, :count).by(1)
      expect(alice.participations.last.target).to eq(@status)
    end

    it "creates the like" do
      expect{ alice.like!(@status) }.to change(Like, :count).by(1)
    end

    it "federates" do
      #participation and like
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Postzord::Dispatcher).to receive(:defer_build_and_post)
      alice.like!(@status)
    end
  end

  describe 'User#like!' do
    before do
      @bobs_aspect = bob.aspects.where(:name => "generic").first
      @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
    end

    it "creates a partcipation" do
      expect{ alice.like!(@status) }.to change(Participation, :count).by(1)
    end

    it "creates the like" do
      expect{ alice.like!(@status) }.to change(Like, :count).by(1)
    end

    it "federates" do
      #participation and like
      expect(Postzord::Dispatcher).to receive(:defer_build_and_post).twice
      alice.like!(@status)
    end

    it "should be able to like on one's own status" do
      like = alice.like!(@status)
      expect(@status.reload.likes.first).to eq(like)
    end

    it "should be able to like on a contact's status" do
      like = bob.like!(@status)
      expect(@status.reload.likes.first).to eq(like)
    end

    it "does not allow multiple likes" do
      alice.like!(@status)
      likes = @status.likes
      expect { alice.like!(@status) }.to raise_error

      expect(@status.reload.likes).to eq(likes)
    end
  end

  describe 'User#participate_in_poll!' do
    before do
      @bobs_aspect = bob.aspects.where(:name => "generic").first
      @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
      @poll = FactoryGirl.create(:poll, :status_message => @status)
      @answer = @poll.poll_answers.first
    end

    it "federates" do
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Postzord::Dispatcher).to receive(:defer_build_and_post)
      alice.participate_in_poll!(@status, @answer)
    end

    it "creates a partcipation" do
      expect{ alice.participate_in_poll!(@status, @answer) }.to change(Participation, :count).by(1)
    end

    it "creates the poll participation" do
      expect{ alice.participate_in_poll!(@status, @answer) }.to change(PollParticipation, :count).by(1)
    end

    it "sets the poll answer id" do
      expect(alice.participate_in_poll!(@status, @answer).poll_answer).to eq(@answer)
    end
  end
end