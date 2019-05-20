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
            .with(kind_of(DiasporaFederation::Entities::StatusMessage), skip_relaying: true)
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
          .with(kind_of(DiasporaFederation::Entities::Comment), skip_relaying: true)
          .and_call_original
        instance.import
        comment = Comment.find_by(guid: guid)
        expect(comment).not_to be_nil
        expect(comment.author).to eq(author.person)
      end

      it "does not relay a remote comment during import" do
        comment_author = FactoryGirl.build(:user)
        comment_author.person.owner = nil
        comment_author.person.pod = Pod.find_or_create_by(url: "http://example.net")
        comment_author.person.save!

        status_message = FactoryGirl.create(:status_message, author: alice.person, public: true)
        comment_data = Fabricate.attributes_for(:comment_entity,
                                                author:      comment_author.diaspora_handle,
                                                parent_guid: status_message.guid).tap do |data|
          data[:author_signature] = Fabricate(:comment_entity, data).sign_with_key(comment_author.encryption_key)
        end

        expect(Diaspora::Federation::Dispatcher).not_to receive(:defer_dispatch)

        ArchiveImporter::EntityImporter.new(Fabricate(:comment_entity, comment_data).to_json.as_json, nil).import
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
