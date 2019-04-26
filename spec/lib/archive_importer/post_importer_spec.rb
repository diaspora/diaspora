# frozen_string_literal: true

require "lib/archive_importer/own_entity_importer_shared"

describe ArchiveImporter::PostImporter do
  describe "#import" do
    let(:old_person) { post.author }
    let(:new_user) { FactoryGirl.create(:user) }
    let(:entity) { Diaspora::Federation::Entities.build(post) }
    let(:entity_json) { entity.to_json.as_json }
    let(:instance) { described_class.new(entity_json, new_user) }

    it_behaves_like "own entity importer" do
      let(:entity_class) { StatusMessage }
      let!(:post) { FactoryGirl.create(:status_message) }

      let(:known_entity_with_correct_author) {
        entity.to_json
      }

      let(:known_entity_with_incorrect_author) {
        result = known_entity_with_correct_author
        result[:entity_data][:author] = FactoryGirl.create(:person).diaspora_handle
        result
      }

      let(:unknown_entity) {
        result = known_entity_with_correct_author
        result[:entity_data][:author] = Fabricate.sequence(:diaspora_id)
        result[:entity_data][:guid] = UUID.generate(:compact)
        result
      }
    end

    context "with subscription" do
      let(:post) { FactoryGirl.build(:status_message, public: true) }
      let(:subscribed_person) { FactoryGirl.create(:person) }
      let(:subscribed_person_id) { subscribed_person.diaspora_handle }

      before do
        entity_json.deep_merge!("subscribed_users_ids" => [subscribed_person_id])
      end

      # TODO: rewrite this test when new subscription implementation is there
      xit "creates a subscription for the post" do
        instance.import

        imported_post = Post.find_by(guid: post.guid)
        expect(imported_post).not_to be_nil
        expect(imported_post.participations.first.author).to eq(subscribed_person)
      end

      context "when subscribed user's account is closed" do
        before do
          AccountDeleter.new(subscribed_person).perform!
        end

        # TODO: rewrite this test when new subscription implementation is there
        xit "doesn't create a subscription" do
          instance.import

          imported_post = Post.find_by(guid: post.guid)
          expect(imported_post).not_to be_nil
          expect(imported_post.participations).to be_empty
        end
      end

      context "when subscribed user has migrated" do
        let(:account_migration) { FactoryGirl.create(:account_migration) }
        let(:subscribed_person) { account_migration.old_person }

        # TODO: rewrite this test when new subscription implementation is there
        xit "creates participation for the new user" do
          instance.import

          imported_post = Post.find_by(guid: post.guid)
          expect(imported_post).not_to be_nil
          expect(imported_post.participations.first.author).to eq(account_migration.new_person)
        end
      end

      context "when subscribed user is not fetchable" do
        let(:subscribed_person_id) { "old_id@old_pod.nowhere" }

        it "doesn't fail" do
          stub_request(
            :get,
            %r{https*://old_pod\.nowhere/\.well-known/webfinger\?resource=acct:old_id@old_pod\.nowhere}
          ).to_return(status: 404, body: "", headers: {})
          stub_request(:get, %r{https*://old_pod\.nowhere/\.well-known/host-meta})
            .to_return(status: 404, body: "", headers: {})

          expect {
            instance.import
          }.not_to raise_error
        end
      end
    end

    context "with photos" do
      let(:photo_entity) { Fabricate(:photo_entity) }
      let(:entity) { Fabricate(:status_message_entity, photos: [photo_entity], author: photo_entity.author) }

      describe "#import" do
        it "substitutes photo author" do
          expect {
            instance.import
          }.not_to raise_error

          photo = Photo.find_by(guid: photo_entity.guid)
          expect(photo).not_to be_nil
          expect(photo.author).to eq(new_user.person)
        end
      end
    end
  end
end
