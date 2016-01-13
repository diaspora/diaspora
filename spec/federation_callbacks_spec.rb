require "spec_helper"
require "diaspora_federation/test"

describe "diaspora federation callbacks" do
  describe ":fetch_person_for_webfinger" do
    it "returns a WebFinger instance with the data from the person" do
      person = alice.person
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, alice.diaspora_handle)
      expect(wf.acct_uri).to eq("acct:#{person.diaspora_handle}")
      expect(wf.alias_url).to eq(AppConfig.url_to("/people/#{person.guid}"))
      expect(wf.hcard_url).to eq(AppConfig.url_to("/hcard/users/#{person.guid}"))
      expect(wf.seed_url).to eq(AppConfig.pod_uri)
      expect(wf.profile_url).to eq(person.profile_url)
      expect(wf.atom_url).to eq(person.atom_url)
      expect(wf.salmon_url).to eq(person.receive_url)
      expect(wf.subscribe_url).to eq(AppConfig.url_to("/people?q={uri}"))
      expect(wf.guid).to eq(person.guid)
      expect(wf.public_key).to eq(person.serialized_public_key)
    end

    it "returns nil if the person was not found" do
      wf = DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, "unknown@example.com")
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
              FactoryGirl.attributes_for(:federation_profile_from_hcard_with_image_url))
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
  let(:post_by_a_local_person) { FactoryGirl.create(:status_message, author: local_person) }
  let(:post_by_a_remote_person) { FactoryGirl.create(:status_message, author: remote_person) }

  describe ":fetch_private_key_by_diaspora_id" do
    it "returns a private key for a local user" do
      key = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, local_person.diaspora_handle)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(local_person.owner.serialized_private_key)
    end

    it "returns nil for a remote user" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, remote_person.diaspora_handle)
      ).to be_nil
    end

    it "returns nil for an unknown id" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, FactoryGirl.generate(:diaspora_id))
      ).to be_nil
    end
  end

  describe ":fetch_author_private_key_by_entity_guid" do
    it "returns a private key for a post by a local user" do
      key = DiasporaFederation.callbacks.trigger(:fetch_author_private_key_by_entity_guid,
                                                 "Post", post_by_a_local_person.guid)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(post_by_a_local_person.author.owner.serialized_private_key)
    end

    it "returns nil for a post by a remote user" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_author_private_key_by_entity_guid,
                                             "Post", post_by_a_remote_person.guid)
      ).to be_nil
    end

    it "returns nil for an unknown post" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_author_private_key_by_entity_guid,
                                             "Post", FactoryGirl.generate(:guid))
      ).to be_nil
    end
  end

  describe ":fetch_public_key_by_diaspora_id" do
    it "returns a public key for a person" do
      key = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, remote_person.diaspora_handle)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(remote_person.serialized_public_key)
    end

    it "returns nil for an unknown person" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, FactoryGirl.generate(:diaspora_id))
      ).to be_nil
    end
  end

  describe ":fetch_author_public_key_by_entity_guid" do
    it "returns a public key for a known post" do
      key = DiasporaFederation.callbacks.trigger(:fetch_author_public_key_by_entity_guid,
                                                 "Post", post_by_a_remote_person.guid)
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.to_s).to eq(post_by_a_remote_person.author.serialized_public_key)
    end

    it "returns nil for an unknown post" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_author_public_key_by_entity_guid,
                                             "Post", FactoryGirl.generate(:guid))
      ).to be_nil
    end
  end

  describe ":entity_author_is_local?" do
    it "returns true for a post by a local user" do
      expect(
        DiasporaFederation.callbacks.trigger(:entity_author_is_local?, "Post", post_by_a_local_person.guid)
      ).to be_truthy
    end

    it "returns false for a post by a remote user" do
      expect(
        DiasporaFederation.callbacks.trigger(:entity_author_is_local?, "Post", post_by_a_remote_person.guid)
      ).to be_falsey
    end

    it "returns false for a unknown post" do
      expect(
        DiasporaFederation.callbacks.trigger(:entity_author_is_local?, "Post", FactoryGirl.generate(:diaspora_id))
      ).to be_falsey
    end
  end

  describe ":fetch_entity_author_id_by_guid" do
    it "returns id for a existing guid" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_entity_author_id_by_guid, "Post", post_by_a_remote_person.guid)
      ).not_to eq(post_by_a_remote_person.author_id)
    end

    it "returns nil for a non-existing guid" do
      expect(
        DiasporaFederation.callbacks.trigger(:fetch_entity_author_id_by_guid, "Post", FactoryGirl.generate(:guid))
      ).to be_nil
    end
  end

  describe ":queue_public_receive" do
    it "enqueues a ReceiveUnencryptedSalmon job" do
      xml = "<diaspora/>"
      expect(Workers::ReceiveUnencryptedSalmon).to receive(:perform_async).with(xml)

      DiasporaFederation.callbacks.trigger(:queue_public_receive, xml)
    end
  end

  describe ":queue_private_receive" do
    let(:xml) { "<diaspora/>" }

    it "returns true if the user is found" do
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, alice.person.guid, xml)
      expect(result).to be_truthy
    end

    it "enqueues a ReceiveEncryptedSalmon job" do
      expect(Workers::ReceiveEncryptedSalmon).to receive(:perform_async).with(alice.id, xml)

      DiasporaFederation.callbacks.trigger(:queue_private_receive, alice.person.guid, xml)
    end

    it "returns false if the no user is found" do
      person = FactoryGirl.create(:person)
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, person.guid, xml)
      expect(result).to be_falsey
    end

    it "returns false if the no person is found" do
      result = DiasporaFederation.callbacks.trigger(:queue_private_receive, "2398rq3948yftn", xml)
      expect(result).to be_falsey
    end
  end
end
