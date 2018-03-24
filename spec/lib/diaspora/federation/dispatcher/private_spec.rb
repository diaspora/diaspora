# frozen_string_literal: true

describe Diaspora::Federation::Dispatcher::Private do
  let(:post) { FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: false) }
  let(:comment) { FactoryGirl.create(:comment, author: alice.person, post: post) }

  before do
    alice.share_with(remote_raphael, alice.aspects.first)
    alice.add_to_streams(post, [alice.aspects.first])
  end

  describe "#dispatch" do
    context "deliver to local user" do
      it "delivers to each user only once" do
        aspect1 = alice.aspects.first
        aspect2 = alice.aspects.create(name: "cat people")
        alice.add_contact_to_aspect(alice.contact_for(bob.person), aspect2)

        post = FactoryGirl.create(
          :status_message,
          author:  alice.person,
          text:    "hello",
          public:  false,
          aspects: [aspect1, aspect2]
        )

        expect(Workers::ReceiveLocal).to receive(:perform_async).with("StatusMessage", post.id, [bob.id])
        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end
    end

    context "deliver to remote user" do
      let(:encryption_key) { double }
      let(:magic_env) { double }
      let(:magic_env_xml) { double }
      let(:json) { "{\"aes_key\": \"...\", \"encrypted_magic_envelope\": \"...\"}" }

      it "queues a private send job" do
        expect(Workers::SendPrivate).to receive(:perform_async) do |user_id, _entity_string, targets|
          expect(user_id).to eq(alice.id)
          expect(targets.size).to eq(1)
          expect(targets).to have_key(remote_raphael.receive_url)
          expect(targets[remote_raphael.receive_url]).to eq(json)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)
        expect(DiasporaFederation::Salmon::EncryptedMagicEnvelope).to receive(:encrypt) do |magic_env, public_key|
          expect(magic_env).to eq(magic_env_xml)
          expect(public_key.to_s).to eq(remote_raphael.public_key.to_s)
          json
        end

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not queue a private send job when no remote recipients specified" do
        bobs_post = FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: false)
        bob.add_to_streams(bobs_post, [bob.aspects.first])

        expect(Workers::SendPrivate).not_to receive(:perform_async)

        Diaspora::Federation::Dispatcher.build(bob, bobs_post).dispatch
      end

      it "queues private send job for a specific subscriber" do
        remote_person = FactoryGirl.create(:person)

        expect(Workers::SendPrivate).to receive(:perform_async) do |user_id, _entity_string, targets|
          expect(user_id).to eq(alice.id)
          expect(targets.size).to eq(1)
          expect(targets).to have_key(remote_person.receive_url)
          expect(targets[remote_person.receive_url]).to eq(json)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)
        expect(DiasporaFederation::Salmon::EncryptedMagicEnvelope).to receive(:encrypt) do |magic_env, public_key|
          expect(magic_env).to eq(magic_env_xml)
          expect(public_key.to_s).to eq(remote_person.public_key.to_s)
          json
        end

        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [remote_person]).dispatch
      end

      it "only queues a private send job for a active pods" do
        remote_person = FactoryGirl.create(:person)
        offline_pod = FactoryGirl.create(:pod, status: :net_failed, offline_since: DateTime.now.utc - 15.days)
        offline_person = FactoryGirl.create(:person, pod: offline_pod)

        expect(Workers::SendPrivate).to receive(:perform_async) do |user_id, _entity_string, targets|
          expect(user_id).to eq(alice.id)
          expect(targets.size).to eq(1)
          expect(targets).to have_key(remote_person.receive_url)
          expect(targets[remote_person.receive_url]).to eq(json)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)
        expect(DiasporaFederation::Salmon::EncryptedMagicEnvelope).to receive(:encrypt) do |magic_env, public_key|
          expect(magic_env).to eq(magic_env_xml)
          expect(public_key.to_s).to eq(remote_person.public_key.to_s)
          json
        end

        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [remote_person, offline_person]).dispatch
      end
    end
  end

  it_behaves_like "a dispatcher"
end
