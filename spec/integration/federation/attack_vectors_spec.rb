# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "integration/federation/federation_helper"

describe "attack vectors", type: :request do
  before do
    allow_callbacks(%i(queue_public_receive queue_private_receive receive_entity fetch_related_entity fetch_public_key))
  end

  let(:eves_aspect) { eve.aspects.find_by_name("generic") }
  let(:alices_aspect) { alice.aspects.find_by_name("generic") }

  it "other users can not grant visiblity to another users posts by sending their friends post to themselves" do
    # setup: eve has a message. then, alice is connected to eve.
    # (meaning alice can not see the old post, but it exists in the DB)
    # bob takes eves message, changes the post author to himself
    # bob trys to send a message to alice

    original_message = eve.post(:status_message, text: "store this!", to: eves_aspect.id)
    original_message.author = bob.person

    alice.share_with(eve.person, alices_aspect)

    post_message(generate_payload(Diaspora::Federation::Entities.post(original_message), bob, alice), alice)

    # alice still should not see eves original post, even though bob sent it to her
    expect(alice.reload.visible_shareables(Post).where(guid: original_message.guid)).to be_blank
  end

  context "author does not match xml author" do
    it "should not overwrite another persons profile" do
      profile = eve.profile.clone
      profile.first_name = "Not BOB"

      post_message(generate_payload(Diaspora::Federation::Entities.profile(profile), alice, bob), bob)

      expect(eve.profile.reload.first_name).not_to eq("Not BOB")
    end

    it "public post should not be spoofed from another author" do
      post = FactoryGirl.build(:status_message, public: true, author: eve.person)

      post_message(generate_payload(Diaspora::Federation::Entities.post(post), alice))

      expect(StatusMessage.exists?(guid: post.guid)).to be_falsey
    end

    it "should not receive retractions where the retractor and the salmon author do not match" do
      original_message = eve.post(:status_message, text: "store this!", to: eves_aspect.id)
      retraction = Retraction.for(original_message)

      expect {
        post_message(generate_payload(Diaspora::Federation::Entities.retraction(retraction), alice, bob), bob)
      }.to_not change { bob.visible_shareables(Post).count(:all) }
    end

    it "should not receive contact retractions from another person" do
      # we are banking on bob being friends with alice and eve
      # here, alice is trying to disconnect bob and eve
      contact = bob.contacts.reload.find_by(person_id: eve.person.id)
      expect(contact).to be_sharing

      post_message(
        generate_payload(Diaspora::Federation::Entities.retraction(ContactRetraction.for(contact)), alice, bob), bob
      )

      expect(bob.contacts.reload.find_by(person_id: eve.person.id)).to be_sharing
    end
  end

  it "does not save a message over an old message with a different author" do
    # setup:  A user has a message with a given guid and author
    original_message = eve.post(:status_message, text: "store this!", to: eves_aspect.id)

    # someone else tries to make a message with the same guid
    malicious_message = FactoryGirl.build(
      :status_message,
      id:     original_message.id,
      guid:   original_message.guid,
      author: alice.person
    )

    post_message(generate_payload(Diaspora::Federation::Entities.post(malicious_message), alice, bob), bob)

    expect(original_message.reload.author_id).to eq(eve.person.id)
  end

  it "does not save a message over an old message with the same author" do
    # setup:
    # I have a legit message from eve
    original_message = eve.post(:status_message, text: "store this!", to: eves_aspect.id)

    # eve tries to send me another message with the same ID
    malicious_message = FactoryGirl.build(:status_message, id: original_message.id, text: "BAD!!!", author: eve.person)

    post_message(generate_payload(Diaspora::Federation::Entities.post(malicious_message), eve, bob), bob)

    expect(original_message.reload.text).to eq("store this!")
  end

  it "ignores retractions on a post not owned by the retraction's sender" do
    original_message = eve.post(:status_message, text: "store this!", to: eves_aspect.id)

    retraction = DiasporaFederation::Entities::Retraction.new(
      target_guid: original_message.guid,
      target_type: original_message.class.to_s,
      target:      Diaspora::Federation::Entities.related_entity(original_message),
      author:      alice.person.diaspora_handle
    )

    expect {
      post_message(generate_payload(retraction, alice, bob), bob)
    }.to_not change(StatusMessage, :count)
  end

  it "does not let another user update other persons post" do
    original_message = eve.post(:photo, user_file: uploaded_photo, text: "store this!", to: eves_aspect.id)

    new_message = original_message.dup
    new_message.author = alice.person
    new_message.text = "bad bad bad"
    new_message.height = 23
    new_message.width = 42

    post_message(generate_payload(Diaspora::Federation::Entities.photo(new_message), alice, bob), bob)

    expect(original_message.reload.text).to eq("store this!")
  end
end
