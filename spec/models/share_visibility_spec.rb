# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ShareVisibility, type: :model do
  describe ".batch_import" do
    let(:post) { FactoryGirl.create(:status_message, author: alice.person) }

    it "returns false if share is public" do
      post.public = true
      post.save
      expect(ShareVisibility.batch_import([bob.id], post)).to be false
    end

    it "creates a visibility for each user" do
      expect {
        ShareVisibility.batch_import([bob.id], post)
      }.to change {
        ShareVisibility.exists?(user_id: bob.id, shareable_id: post.id, shareable_type: "Post")
      }.from(false).to(true)
    end

    it "does not raise if a visibility already exists" do
      ShareVisibility.create!(user_id: bob.id, shareable_id: post.id, shareable_type: "Post")
      expect {
        ShareVisibility.batch_import([bob.id], post)
      }.not_to raise_error
    end

    it "does not create visibilities for a public shareable" do
      public_post = FactoryGirl.create(:status_message, author: alice.person, public: true)

      ShareVisibility.batch_import([bob.id], public_post)
      expect(ShareVisibility.where(user_id: bob.id, shareable_id: post.id, shareable_type: "Post")).not_to exist
    end

    context "scopes" do
      before do
        alice.post(:status_message, text: "Hey", to: alice.aspects.first)

        photo_path = File.join(File.dirname(__FILE__), "..", "fixtures", "button.png")
        alice.post(:photo, user_file: File.open(photo_path), text: "Photo", to: alice.aspects.first)
      end

      describe ".for_a_user" do
        it "searches for share visibilies for a user" do
          expect(ShareVisibility.for_a_user(bob).count).to eq(2)
          expect(ShareVisibility.for_a_user(bob)).to eq(ShareVisibility.where(user_id: bob.id).to_a)
        end
      end
    end
  end
end
