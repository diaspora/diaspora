# frozen_string_literal: true

require "diaspora_federation/test"

describe "diaspora federation callbacks" do
  describe ":fetch_person_for_webfinger" do
    it "returns a WebFinger instance with the data from the person" do
      person = alice.person
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, alice.diaspora_handle)
      expect(wf.acct_uri).to eq("acct:#{person.diaspora_handle}")
      expect(wf.hcard_url).to eq(AppConfig.url_to("/hcard/users/#{person.guid}"))
      expect(wf.seed_url).to eq(AppConfig.pod_uri)
      expect(wf.profile_url).to eq(person.profile_url)
      expect(wf.atom_url).to eq(person.atom_url)
      expect(wf.salmon_url).to eq(person.receive_url)
      expect(wf.subscribe_url).to eq(AppConfig.url_to("/people?q={uri}"))
    end

    it "contains the OpenID issuer" do
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, alice.diaspora_handle)
      links = wf.additional_data[:links]
      openid_issuer = links.find {|l| l[:rel] == OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE }
      expect(openid_issuer).not_to be_nil
      expect(openid_issuer[:href]).to eq(Rails.application.routes.url_helpers.root_url)
    end

    it "returns nil if the person was not found" do
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, "unknown@example.com")
      expect(wf).to be_nil
    end

    it "returns nil for a remote person" do
      person = FactoryGirl.create(:person)
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, person.diaspora_handle)
      expect(wf).to be_nil
    end

    it "returns nil for a closed account" do
      user = FactoryGirl.create(:user)
      user.person.lock_access!
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, user.diaspora_handle)
      expect(wf).to be_nil
    end
  end

  describe ":fetch_person_for_hcard" do
    it "returns a HCard instance with the data from the person" do
      person = alice.person
      hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, alice.guid)
      expect(hcard.guid).to eq(person.guid)
      expect(hcard.nickname).to eq(person.username)
      expect(hcard.full_name).to eq("#{person.profile.first_name} #{person.profile.last_name}")
      expect(hcard.url).to eq(AppConfig.pod_uri)
      expect(hcard.photo_large_url).to eq(person.image_url)
      expect(hcard.photo_medium_url).to eq(person.image_url(:thumb_medium))
      expect(hcard.photo_small_url).to eq(person.image_url(:thumb_small))
      expect(hcard.public_key).to eq(person.serialized_public_key)
      expect(hcard.searchable).to eq(person.searchable)
      expect(hcard.first_name).to eq(person.profile.first_name)
      expect(hcard.last_name).to eq(person.profile.last_name)
    end

    it "trims the full_name" do
      user = FactoryGirl.create(:user)
      user.person.profile.last_name = nil
      user.person.profile.save

      hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, user.guid)
      expect(hcard.full_name).to eq(user.person.profile.first_name)
    end

    it "returns nil if the person was not found" do
      hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, "1234567890abcdef")
      expect(hcard).to be_nil
    end

    it "returns nil for a remote person" do
      person = FactoryGirl.create(:person)
      hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, person.guid)
      expect(hcard).to be_nil
    end

    it "returns nil for a closed account" do
      user = FactoryGirl.create(:user)
      user.person.lock_access!
      hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, user.guid)
      expect(hcard).to be_nil
    end
  end

  describe ":save_person_after_webfinger" do
    context "new person" do
      it "creates a new person" do
        person = DiasporaFederation::Entities::Person.new(FactoryGirl.attributes_for(:federation_person_from_webfinger))

        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)

        person_entity = Person.find_by(diaspora_handle: person.diaspora_id)
        expect(person_entity.guid).to eq(person.guid)
        expect(person_entity.serialized_public_key).to eq(person.exported_key)
        expect(person_entity.url).to eq(person.url)

        profile = person.profile
        profile_entity = person_entity.profile
        expect(profile_entity.first_name).to eq(profile.first_name)
        expect(profile_entity.last_name).to eq(profile.last_name)
        expect(profile_entity[:image_url]).to be_nil
        expect(profile_entity[:image_url_medium]).to be_nil
        expect(profile_entity[:image_url_small]).to be_nil
        expect(profile_entity.searchable).to eq(profile.searchable)
      end

      it "creates a new person with images" do
        person = DiasporaFederation::Entities::Person.new(
          FactoryGirl.attributes_for(
            :federation_person_from_webfinger,
            profile: DiasporaFederation::Entities::Profile.new(
              FactoryGirl.attributes_for(:federation_profile_from_hcard_with_image_url)
            )
          )
        )

        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)

        person_entity = Person.find_by(diaspora_handle: person.diaspora_id)
        expect(person_entity.guid).to eq(person.guid)
        expect(person_entity.serialized_public_key).to eq(person.exported_key)
        expect(person_entity.url).to eq(person.url)

        profile = person.profile
        profile_entity = person_entity.profile
        expect(profile_entity.first_name).to eq(profile.first_name)
        expect(profile_entity.last_name).to eq(profile.last_name)
        expect(profile_entity.image_url).to eq(profile.image_url)
        expect(profile_entity.image_url_medium).to eq(profile.image_url_medium)
        expect(profile_entity.image_url_small).to eq(profile.image_url_small)
        expect(profile_entity.searchable).to eq(profile.searchable)
      end

      it "raises an error if a person with the same GUID already exists" do
        person_data = FactoryGirl.attributes_for(:federation_person_from_webfinger).merge(guid: alice.guid)
        person = DiasporaFederation::Entities::Person.new(person_data)

        expect {
          DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)
        }.to raise_error ActiveRecord::RecordInvalid, /Person with same GUID already exists: #{alice.diaspora_handle}/
      end
    end

    context "update profile" do
      let(:existing_person_entity) { FactoryGirl.create(:person) }
      let(:person) {
        DiasporaFederation::Entities::Person.new(
          FactoryGirl.attributes_for(:federation_person_from_webfinger,
                                     diaspora_id: existing_person_entity.diaspora_handle)
        )
      }

      it "updates an existing profile" do
        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)

        person_entity = Person.find_by(diaspora_handle: existing_person_entity.diaspora_handle)

        profile = person.profile
        profile_entity = person_entity.profile
        expect(profile_entity.first_name).to eq(profile.first_name)
        expect(profile_entity.last_name).to eq(profile.last_name)
      end

      it "should not change the existing person" do
        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)

        person_entity = Person.find_by(diaspora_handle: existing_person_entity.diaspora_handle)
        expect(person_entity.guid).to eq(existing_person_entity.guid)
        expect(person_entity.serialized_public_key).to eq(existing_person_entity.serialized_public_key)
        expect(person_entity.url).to eq(existing_person_entity.url)
      end

      it "creates profile for existing person if no profile present" do
        existing_person_entity.profile = nil
        existing_person_entity.save

        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)

        person_entity = Person.find_by(diaspora_handle: existing_person_entity.diaspora_handle)

        profile = person.profile
        profile_entity = person_entity.profile
        expect(profile_entity.first_name).to eq(profile.first_name)
        expect(profile_entity.last_name).to eq(profile.last_name)
      end
    end
  end

  let(:local_person) { FactoryGirl.create(:user).person }
  let(:remote_person) { FactoryGirl.create(:person) }

  describe ":fetch_private_key" do
    it "returns a private key for a local user" do
      key = DiasporaFederation.callbacks.trigger(:fetch_private_key, local_person.diaspora_handle)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(local_person.owner.serialized_private_key)
    end

    it "returns nil for a remote user" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_private_key, remote_person.diaspora_handle)
      ).to be_nil
    end

    it "returns nil for an unknown id" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_private_key, Fabricate.sequence(:diaspora_id))
      ).to be_nil
    end
  end

  describe ":fetch_public_key" do
    it "returns a public key for a person" do
      key = DiasporaFederation.callbacks.trigger(:fetch_public_key, remote_person.diaspora_handle)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(remote_person.serialized_public_key)
    end

    it "fetches an unknown user" do
      person = FactoryGirl.build(:person)
      expect(Person).to receive(:find_or_fetch_by_identifier).with(person.diaspora_handle).and_return(person)

      key = DiasporaFederation.callbacks.trigger(:fetch_public_key, person.diaspora_handle)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(person.serialized_public_key)
    end

    it "returns nil for an unknown person" do
      diaspora_id = Fabricate.sequence(:diaspora_id)
      expect(Person).to receive(:find_or_fetch_by_identifier).with(diaspora_id)
        .and_raise(DiasporaFederation::Discovery::DiscoveryError)

      expect {
        DiasporaFederation.callbacks.trigger(:fetch_public_key, diaspora_id)
      }.to raise_error DiasporaFederation::Discovery::DiscoveryError
    end
  end

  describe ":fetch_related_entity" do
    it "returns related entity for an existing local post" do
      post = FactoryGirl.create(:status_message, author: local_person)
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", post.guid)
      expect(entity.author).to eq(post.diaspora_handle)
      expect(entity.local).to be_truthy
      expect(entity.public).to be_falsey
      expect(entity.parent).to be_nil
    end

    it "returns related entity for an existing remote post" do
      post = FactoryGirl.create(:status_message, author: remote_person)
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", post.guid)
      expect(entity.author).to eq(post.diaspora_handle)
      expect(entity.local).to be_falsey
      expect(entity.public).to be_falsey
      expect(entity.parent).to be_nil
    end

    it "returns related entity for an existing public post" do
      post = FactoryGirl.create(:status_message, author: local_person, public: true)
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", post.guid)
      expect(entity.author).to eq(post.diaspora_handle)
      expect(entity.local).to be_truthy
      expect(entity.public).to be_truthy
      expect(entity.parent).to be_nil
    end

    it "returns related entity for an existing comment" do
      post = FactoryGirl.create(:status_message, author: local_person, public: true)
      comment = FactoryGirl.create(:comment, author: remote_person, parent: post)
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Comment", comment.guid)
      expect(entity.author).to eq(comment.diaspora_handle)
      expect(entity.local).to be_falsey
      expect(entity.public).to be_truthy
      expect(entity.parent.author).to eq(post.diaspora_handle)
      expect(entity.parent.local).to be_truthy
      expect(entity.parent.public).to be_truthy
      expect(entity.parent.parent).to be_nil
    end

    it "returns related entity for an existing conversation" do
      conversation = FactoryGirl.create(:conversation, author: local_person)
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Conversation", conversation.guid)
      expect(entity.author).to eq(local_person.diaspora_handle)
      expect(entity.local).to be_truthy
      expect(entity.public).to be_falsey
      expect(entity.parent).to be_nil
    end

    it "returns related entity for an existing person" do
      entity = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Person", remote_person.guid)
      expect(entity.author).to eq(remote_person.diaspora_handle)
      expect(entity.local).to be_falsey
      expect(entity.public).to be_falsey
      expect(entity.parent).to be_nil
    end

    it "returns nil for a non-existing guid" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Post", Fabricate.sequence(:guid))
      ).to be_nil
    end
  end

  describe ":queue_public_receive" do
    it "enqueues a ReceivePublic job" do
      data = "<diaspora/>"
      expect(Workers::ReceivePublic).to receive(:perform_async).with(data, true)

      DiasporaFederation.callbacks.trigger(:queue_public_receive, data, true)
    end
  end

  describe ":queue_private_receive" do
    let(:data) { "<diaspora/>" }

    it "returns true if the user is found" do
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, alice.person.guid, data)
      expect(result).to be_truthy
    end

    it "enqueues a ReceivePrivate job" do
      expect(Workers::ReceivePrivate).to receive(:perform_async).with(alice.id, data, true)

      DiasporaFederation.callbacks.trigger(:queue_private_receive, alice.person.guid, data, true)
    end

    it "returns false if the no user is found" do
      person = FactoryGirl.create(:person)
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, person.guid, data, true)
      expect(result).to be_falsey
    end

    it "returns false if the no person is found" do
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, "2398rq3948yftn", data, true)
      expect(result).to be_falsey
    end
  end

  describe ":receive_entity" do
    it "receives an AccountDeletion" do
      account_deletion = Fabricate(:account_deletion_entity, author: remote_person.diaspora_handle)

      expect(Diaspora::Federation::Receive).to receive(:account_deletion).with(account_deletion)
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)

      DiasporaFederation.callbacks.trigger(:receive_entity, account_deletion, account_deletion.author, nil)
    end

    it "receives a Retraction" do
      retraction = Fabricate(:retraction_entity, author: remote_person.diaspora_handle)

      expect(Diaspora::Federation::Receive).to receive(:retraction).with(retraction, 42)
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)

      DiasporaFederation.callbacks.trigger(:receive_entity, retraction, retraction.author, 42)
    end

    it "receives a entity" do
      received = Fabricate(:status_message_entity, author: remote_person.diaspora_handle)
      persisted = FactoryGirl.create(:status_message)

      expect(Diaspora::Federation::Receive).to receive(:perform).with(received).and_return(persisted)
      expect(Workers::ReceiveLocal).to receive(:perform_async).with(persisted.class.to_s, persisted.id, [])

      DiasporaFederation.callbacks.trigger(:receive_entity, received, received.author, nil)
    end

    it "calls schedule_check_if_needed on the senders pod" do
      received = Fabricate(:status_message_entity, author: remote_person.diaspora_handle)
      persisted = FactoryGirl.create(:status_message)

      expect(Person).to receive(:by_account_identifier).with(received.author).and_return(remote_person)
      expect(remote_person.pod).to receive(:schedule_check_if_needed)
      expect(Diaspora::Federation::Receive).to receive(:perform).with(received).and_return(persisted)
      expect(Workers::ReceiveLocal).to receive(:perform_async).with(persisted.class.to_s, persisted.id, [])

      DiasporaFederation.callbacks.trigger(:receive_entity, received, received.author, nil)
    end

    it "receives a entity for a recipient" do
      received = Fabricate(:status_message_entity, author: remote_person.diaspora_handle)
      persisted = FactoryGirl.create(:status_message)

      expect(Diaspora::Federation::Receive).to receive(:perform).with(received).and_return(persisted)
      expect(Workers::ReceiveLocal).to receive(:perform_async).with(persisted.class.to_s, persisted.id, [42])

      DiasporaFederation.callbacks.trigger(:receive_entity, received, received.author, 42)
    end

    it "does not trigger a ReceiveLocal job if Receive.perform returned nil" do
      received = Fabricate(:status_message_entity, author: remote_person.diaspora_handle)

      expect(Diaspora::Federation::Receive).to receive(:perform).with(received).and_return(nil)
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)

      DiasporaFederation.callbacks.trigger(:receive_entity, received, received.author, nil)
    end
  end

  describe ":fetch_public_entity" do
    it "fetches a Post" do
      post = FactoryGirl.create(:status_message, author: alice.person, public: true)
      entity = DiasporaFederation.callbacks.trigger(:fetch_public_entity, "Post", post.guid)

      expect(entity.guid).to eq(post.guid)
      expect(entity.author).to eq(alice.diaspora_handle)
      expect(entity.public).to be_truthy
    end

    it "fetches a StatusMessage" do
      post = FactoryGirl.create(:status_message, author: alice.person, public: true)
      entity = DiasporaFederation.callbacks.trigger(:fetch_public_entity, "StatusMessage", post.guid)

      expect(entity.guid).to eq(post.guid)
      expect(entity.author).to eq(alice.diaspora_handle)
      expect(entity.public).to be_truthy
    end

    it "fetches a Reshare" do
      post = FactoryGirl.create(:reshare, author: alice.person, public: true)
      entity = DiasporaFederation.callbacks.trigger(:fetch_public_entity, "Reshare", post.guid)

      expect(entity.guid).to eq(post.guid)
      expect(entity.author).to eq(alice.diaspora_handle)
    end

    it "does not fetch a private post" do
      post = FactoryGirl.create(:status_message, author: alice.person, public: false)

      expect(
        DiasporaFederation.callbacks.trigger(:fetch_public_entity, "StatusMessage", post.guid)
      ).to be_nil
    end

    it "returns nil, if the post is unknown" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_public_entity, "Post", "unknown-guid")
      ).to be_nil
    end
  end

  describe ":fetch_person_url_to" do
    it "returns the url with with the pod of the person" do
      pod = FactoryGirl.create(:pod)
      person = FactoryGirl.create(:person, pod: pod)

      expect(
        DiasporaFederation.callbacks.trigger(:fetch_person_url_to, person.diaspora_handle, "/path/on/pod")
      ).to eq("https://#{pod.host}/path/on/pod")
    end

    it "fetches an unknown user" do
      pod = FactoryGirl.build(:pod)
      person = FactoryGirl.build(:person, pod: pod)
      expect(Person).to receive(:find_or_fetch_by_identifier).with(person.diaspora_handle).and_return(person)

      expect(
        DiasporaFederation.callbacks.trigger(:fetch_person_url_to, person.diaspora_handle, "/path/on/pod")
      ).to eq("https://#{pod.host}/path/on/pod")
    end

    it "forwards the DiscoveryError" do
      diaspora_id = Fabricate.sequence(:diaspora_id)
      expect(Person).to receive(:find_or_fetch_by_identifier).with(diaspora_id)
        .and_raise(DiasporaFederation::Discovery::DiscoveryError)

      expect {
        DiasporaFederation.callbacks.trigger(:fetch_person_url_to, diaspora_id, "/path/on/pod")
      }.to raise_error DiasporaFederation::Discovery::DiscoveryError
    end
  end

  describe ":update_pod" do
    let(:pod) { FactoryGirl.create(:pod) }
    let(:pod_url) { pod.url_to("/") }

    it "sets the correct error for curl-errors" do
      pod = FactoryGirl.create(:pod)

      DiasporaFederation.callbacks.trigger(:update_pod, pod.url_to("/"), :ssl_cacert)

      updated_pod = Pod.find_or_create_by(url: pod.url_to("/"))
      expect(Pod.statuses[updated_pod.status]).to eq(Pod.statuses[:ssl_failed])
      expect(updated_pod.error).to eq("FederationError: ssl_cacert")
    end

    it "sets :no_errors to a pod that was down but up now and return code 202" do
      pod = FactoryGirl.create(:pod, status: :unknown_error)

      DiasporaFederation.callbacks.trigger(:update_pod, pod.url_to("/"), 202)

      updated_pod = Pod.find_or_create_by(url: pod.url_to("/"))
      expect(Pod.statuses[updated_pod.status]).to eq(Pod.statuses[:no_errors])
    end

    it "does not change a pod that has status :version_failed and was successful" do
      pod = FactoryGirl.create(:pod, status: :version_failed)

      DiasporaFederation.callbacks.trigger(:update_pod, pod.url_to("/"), 202)

      updated_pod = Pod.find_or_create_by(url: pod.url_to("/"))
      expect(Pod.statuses[updated_pod.status]).to eq(Pod.statuses[:version_failed])
    end

    it "sets :http_failed if it has an unsuccessful http status code" do
      pod = FactoryGirl.create(:pod)

      DiasporaFederation.callbacks.trigger(:update_pod, pod.url_to("/"), 404)

      updated_pod = Pod.find_or_create_by(url: pod.url_to("/"))
      expect(Pod.statuses[updated_pod.status]).to eq(Pod.statuses[:http_failed])
      expect(updated_pod.error).to eq("FederationError: HTTP status code was: 404")
    end
  end
end
