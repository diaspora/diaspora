# frozen_string_literal: true

describe Diaspora::Federation::Dispatcher::Public do
  let(:post) { FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: true) }
  let(:comment) { FactoryGirl.create(:comment, author: alice.person, post: post) }

  describe "#dispatch" do
    context "pubsubhubbub" do
      it "delivers public posts to pubsubhubbub" do
        expect(Workers::PublishToHub).to receive(:perform_async).with(alice.atom_url)
        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not call pubsubhubbub for comments" do
        expect(Workers::PublishToHub).not_to receive(:perform_async)
        Diaspora::Federation::Dispatcher.build(alice, comment).dispatch
      end
    end

    context "relay functionality" do
      before do
        AppConfig.relay.outbound.url = "https://relay.iliketoast.net/receive/public"
      end

      it "delivers public post to relay when relay is enabled" do
        AppConfig.relay.outbound.send = true

        expect(Workers::SendPublic).to receive(:perform_async) do |_user_id, _entity_string, urls, _xml|
          expect(urls).to include("https://relay.iliketoast.net/receive/public")
        end

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not deliver post to relay when relay is disabled" do
        AppConfig.relay.outbound.send = false

        expect(Workers::SendPublic).not_to receive(:perform_async)

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not deliver comments to relay" do
        AppConfig.relay.outbound.send = true

        expect(Workers::SendPublic).not_to receive(:perform_async)

        Diaspora::Federation::Dispatcher.build(alice, comment).dispatch
      end
    end

    context "deliver to remote user" do
      let(:encryption_key) { double }
      let(:magic_env) { double }
      let(:magic_env_xml) { double(to_xml: "<diaspora/>") }

      it "queues a public send job" do
        alice.share_with(remote_raphael, alice.aspects.first)

        expect(Workers::SendPublic).to receive(:perform_async) do |user_id, _entity_string, urls, xml|
          expect(user_id).to eq(alice.id)
          expect(urls.size).to eq(1)
          expect(urls[0]).to eq(remote_raphael.pod.url_to("/receive/public"))
          expect(xml).to eq(magic_env_xml.to_xml)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "does not queue a public send job when no remote recipients specified" do
        expect(Workers::SendPublic).not_to receive(:perform_async)

        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "queues public send job for a specific subscriber" do
        expect(Workers::SendPublic).to receive(:perform_async) do |user_id, _entity_string, urls, xml|
          expect(user_id).to eq(alice.id)
          expect(urls.size).to eq(1)
          expect(urls[0]).to eq(remote_raphael.pod.url_to("/receive/public"))
          expect(xml).to eq(magic_env_xml.to_xml)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)
        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [remote_raphael]).dispatch
      end

      it "only queues a public send job for a active pods" do
        offline_pod = FactoryGirl.create(:pod, status: :net_failed, offline_since: DateTime.now.utc - 15.days)
        offline_person = FactoryGirl.create(:person, pod: offline_pod)

        expect(Workers::SendPublic).to receive(:perform_async) do |user_id, _entity_string, urls, xml|
          expect(user_id).to eq(alice.id)
          expect(urls.size).to eq(1)
          expect(urls[0]).to eq(remote_raphael.pod.url_to("/receive/public"))
          expect(xml).to eq(magic_env_xml.to_xml)
        end

        expect(alice).to receive(:encryption_key).and_return(encryption_key)
        expect(DiasporaFederation::Salmon::MagicEnvelope).to receive(:new).with(
          instance_of(DiasporaFederation::Entities::StatusMessage), alice.diaspora_handle
        ).and_return(magic_env)
        expect(magic_env).to receive(:envelop).with(encryption_key).and_return(magic_env_xml)

        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [remote_raphael, offline_person]).dispatch
      end
    end
  end

  it_behaves_like "a dispatcher"
end
