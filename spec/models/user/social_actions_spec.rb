# frozen_string_literal: true

describe User::SocialActions, type: :model do
  let(:status) { FactoryGirl.create(:status_message, public: true, author: bob.person) }

  describe "User#comment!" do
    it "sets the comment text" do
      expect(alice.comment!(status, "unicorn_mountain").text).to eq("unicorn_mountain")
    end

    it "creates a participation" do
      expect { alice.comment!(status, "bro") }.to change(Participation, :count).by(1)
      expect(alice.participations.last.target).to eq(status)
      expect(alice.participations.last.count).to eq(1)
    end

    it "does not create a participation for the post author" do
      expect { bob.comment!(status, "bro") }.not_to change(Participation, :count)
    end

    it "creates the comment" do
      expect { alice.comment!(status, "bro") }.to change(Comment, :count).by(1)
    end

    it "federates" do
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
      alice.comment!(status, "omg")
    end
  end

  describe "User#like!" do
    it "creates a participation" do
      expect { alice.like!(status) }.to change(Participation, :count).by(1)
      expect(alice.participations.last.target).to eq(status)
    end

    it "does not create a participation for the post author" do
      expect { bob.like!(status) }.not_to change(Participation, :count)
    end

    it "creates the like" do
      expect { alice.like!(status) }.to change(Like, :count).by(1)
    end

    it "federates" do
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
      alice.like!(status)
    end

    it "should be able to like on one's own status" do
      like = bob.like!(status)
      expect(status.reload.likes.first).to eq(like)
    end

    it "should be able to like on a contact's status" do
      like = alice.like!(status)
      expect(status.reload.likes.first).to eq(like)
    end

    it "does not allow multiple likes" do
      alice.like!(status)
      likes = status.likes
      expect { alice.like!(status) }.to raise_error ActiveRecord::RecordInvalid

      expect(status.reload.likes).to eq(likes)
    end
  end

  describe "User#participate_in_poll!" do
    let(:poll) { FactoryGirl.create(:poll, status_message: status) }
    let(:answer) { poll.poll_answers.first }

    it "federates" do
      allow_any_instance_of(Participation::Generator).to receive(:create!)
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
      alice.participate_in_poll!(status, answer)
    end

    it "creates a participation" do
      expect { alice.participate_in_poll!(status, answer) }.to change(Participation, :count).by(1)
    end

    it "does not create a participation for the post author" do
      expect { bob.participate_in_poll!(status, answer) }.not_to change(Participation, :count)
    end

    it "creates the poll participation" do
      expect { alice.participate_in_poll!(status, answer) }.to change(PollParticipation, :count).by(1)
    end

    it "sets the poll answer id" do
      expect(alice.participate_in_poll!(status, answer).poll_answer).to eq(answer)
    end
  end

  describe "many actions" do
    it "two comments" do
      alice.comment!(status, "bro...")
      alice.comment!(status, "...ther")
      expect(alice.participations.last.count).to eq(2)
    end

    it "like and comment" do
      alice.comment!(status, "bro...")
      alice.like!(status)
      expect(alice.participations.last.count).to eq(2)
    end
  end
end
