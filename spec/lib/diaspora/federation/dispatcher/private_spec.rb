require "spec_helper"

describe Diaspora::Federation::Dispatcher::Private do
  let(:post) { FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: false) }
  let(:comment) { FactoryGirl.create(:comment, author: alice.person, post: post) }

  before do
    alice.share_with(remote_raphael, alice.aspects.first)
    alice.add_to_streams(post, [alice.aspects.first])
  end

  describe "#dispatch" do
    context "deliver to remote user" do
      it "queues a private send job" do
        xml = "<diaspora/>"

        expect(Workers::SendPrivate).to receive(:perform_async) do |user_id, _entity_string, targets|
          expect(user_id).to eq(alice.id)
          expect(targets.size).to eq(1)
          expect(targets).to have_key(remote_raphael.receive_url)
          expect(targets[remote_raphael.receive_url]).to eq(xml)
        end

        salmon = double
        expect(DiasporaFederation::Salmon::EncryptedSlap).to receive(:prepare).and_return(salmon)
        expect(salmon).to receive(:generate_xml).and_return(xml)

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not queue a private send job when no remote recipients specified" do
        bobs_post = FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: false)
        bob.add_to_streams(bobs_post, [bob.aspects.first])

        expect(Workers::SendPrivate).not_to receive(:perform_async)

        Diaspora::Federation::Dispatcher.build(bob, bobs_post).dispatch
      end
    end
  end

  it_behaves_like "a dispatcher"
end
