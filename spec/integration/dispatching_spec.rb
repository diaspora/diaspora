# frozen_string_literal: true

describe "Dispatching", type: :request do
  context "a comment retraction on a public post" do
    it "triggers a public dispatch" do
      # Alice has a public post and comments on it
      post = FactoryGirl.create(:status_message, public: true, author: alice.person)

      comment = alice.comment!(post, "awesomesauseum")

      inlined_jobs do
        # Alice now retracts her comment
        expect(Diaspora::Federation::Dispatcher::Public).to receive(:new).and_return(double(dispatch: true))
        expect(Diaspora::Federation::Dispatcher::Private).not_to receive(:new)
        alice.retract(comment)
      end
    end
  end

  context "a comment retraction on a private post" do
    it "triggers a private dispatch" do
      # Alice has a private post and comments on it
      post = alice.post(:status_message, text: "hello", to: alice.aspects.first)

      comment = alice.comment!(post, "awesomesauseum")

      inlined_jobs do
        # Alice now retracts her comment
        expect(Diaspora::Federation::Dispatcher::Public).not_to receive(:new)
        expect(Diaspora::Federation::Dispatcher::Private).to receive(:new).and_return(double(dispatch: true))
        alice.retract(comment)
      end
    end
  end
end
