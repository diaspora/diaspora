# frozen_string_literal: true

describe ArchiveImporter::EntityImporter do
  let(:instance) { ArchiveImporter::EntityImporter.new(json, nil) }

  describe "#import" do
    context "with status_message" do
      let(:guid) { UUID.generate(:compact) }
      let(:json) { JSON.parse(<<~JSON) }
        {
          "entity_data" : {
             "created_at" : "2015-10-19T13:58:16Z",
             "guid" : "#{guid}",
             "text" : "test post",
             "author" : "author@example.com"
          },
          "entity_type" : "status_message"
        }
      JSON

      context "with known author" do
        let!(:author) { FactoryGirl.create(:person, diaspora_handle: "author@example.com") }

        it "runs entity receive routine" do
          expect(Diaspora::Federation::Receive).to receive(:perform)
            .with(kind_of(DiasporaFederation::Entities::StatusMessage))
            .and_call_original
          instance.import

          status_message = StatusMessage.find_by(guid: guid)
          expect(status_message).not_to be_nil
          expect(status_message.author).to eq(author)
        end
      end

      context "with unknown author" do
        it "handles missing person" do
          expect {
            instance.import
          }.not_to raise_error

          expect(StatusMessage.find_by(guid: guid)).to be_nil
        end
      end
    end

    context "with comment" do
      let(:status_message) { FactoryGirl.create(:status_message) }
      let(:author) { FactoryGirl.create(:user) }
      let(:comment_entity) {
        data = Fabricate.attributes_for(:comment_entity,
                                        author:      author.diaspora_handle,
                                        parent_guid: status_message.guid)
        data[:author_signature] = Fabricate(:comment_entity, data).sign_with_key(author.encryption_key)
        Fabricate(:comment_entity, data)
      }
      let(:guid) { comment_entity.guid }
      let(:json) { comment_entity.to_json.as_json }

      it "runs entity receive routine" do
        expect(Diaspora::Federation::Receive).to receive(:perform)
          .with(kind_of(DiasporaFederation::Entities::Comment))
          .and_call_original
        instance.import
        comment = Comment.find_by(guid: guid)
        expect(comment).not_to be_nil
        expect(comment.author).to eq(author.person)
      end

      it "rescues DiasporaFederation::Entities::Signable::SignatureVerificationFailed" do
        expect(Person).to receive(:find_or_fetch_by_identifier)
          .with(author.diaspora_handle)
          .and_raise DiasporaFederation::Entities::Signable::SignatureVerificationFailed

        expect {
          instance.import
        }.not_to raise_error
      end

      it "rescues DiasporaFederation::Discovery::InvalidDocument" do
        expect(Person).to receive(:find_or_fetch_by_identifier)
          .with(author.diaspora_handle)
          .and_raise DiasporaFederation::Discovery::InvalidDocument

        expect {
          instance.import
        }.not_to raise_error
      end

      it "rescues DiasporaFederation::Discovery::DiscoveryError" do
        expect(Person).to receive(:find_or_fetch_by_identifier)
          .with(author.diaspora_handle)
          .and_raise DiasporaFederation::Discovery::DiscoveryError

        expect {
          instance.import
        }.not_to raise_error
      end
    end
  end
end
