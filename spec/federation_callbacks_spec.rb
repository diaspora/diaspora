require "spec_helper"

describe "diaspora federation callbacks" do
  describe ":person_webfinger_fetch" do
    it "returns a WebFinger instance with the data from the person" do
      person = alice.person
      wf = DiasporaFederation.callbacks.trigger(:person_webfinger_fetch, alice.diaspora_handle)
      expect(wf.acct_uri).to eq("acct:#{person.diaspora_handle}")
      expect(wf.alias_url).to eq(AppConfig.url_to("/people/#{person.guid}"))
      expect(wf.hcard_url).to eq(AppConfig.url_to("/hcard/users/#{person.guid}"))
      expect(wf.seed_url).to eq(AppConfig.pod_uri)
      expect(wf.profile_url).to eq(person.profile_url)
      expect(wf.atom_url).to eq(person.atom_url)
      expect(wf.salmon_url).to eq(person.receive_url)
      expect(wf.guid).to eq(person.guid)
      expect(wf.public_key).to eq(person.serialized_public_key)
    end

    it "returns nil if the person was not found" do
      wf = DiasporaFederation.callbacks.trigger(:person_webfinger_fetch, "unknown@example.com")
      expect(wf).to be_nil
    end
  end

  describe ":person_hcard_fetch" do
    it "returns a HCard instance with the data from the person" do
      person = alice.person
      hcard = DiasporaFederation.callbacks.trigger(:person_hcard_fetch, alice.guid)
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

      hcard = DiasporaFederation.callbacks.trigger(:person_hcard_fetch, user.guid)
      expect(hcard.full_name).to eq(user.person.profile.first_name)
    end

    it "returns nil if the person was not found" do
      hcard = DiasporaFederation.callbacks.trigger(:person_hcard_fetch, "1234567890abcdef")
      expect(hcard).to be_nil
    end
  end
end
