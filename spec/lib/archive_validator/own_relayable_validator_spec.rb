# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::OwnRelayableValidator do
  include_context "validators shared context"
  include_context "relayable validator context"

  let(:relayable_entity) { :comment_entity }
  let(:author) { FactoryGirl.create(:user).person }

  let(:relayable_author) {
    author_id
  }

  def create_root
    FactoryGirl.create(:status_message, guid: parent_guid)
  end

  before do
    relayable["entity_data"].delete("author_signature")
    create_root
  end

  it_behaves_like "a relayable validator"

  context "when root is unknown" do
    def create_root; end

    context "it fetches root" do
      before do
        expect(DiasporaFederation::Federation::Fetcher)
          .to receive(:fetch_public)
            .with(author.diaspora_handle, "Post", parent_guid) {
              FactoryGirl.create(:status_message, guid: parent_guid)
            }
      end

      include_examples "validation result is valid"
    end

    context "when root is in the archive and is an own post" do
      before do
        include_in_input_archive(
          user: {
            posts: [
              entity_data: {
                text:       "123456",
                created_at: "2017-07-03T08:12:25Z",
                photos:     [],
                author:     author_id,
                public:     false,
                guid:       parent_guid
              },
              entity_type: "status_message"
            ]
          }
        )

        expect(DiasporaFederation::Federation::Fetcher)
          .not_to receive(:fetch_public)
      end

      include_examples "validation result is valid"
    end

    context "when fetching fails" do
      before do
        expect(DiasporaFederation::Federation::Fetcher)
          .to receive(:fetch_public)
          .with(author.diaspora_handle, "Post", parent_guid)
          .and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)
      end

      it "is not valid and contains a message" do
        expect(validator.valid?).to be_falsey
        expect(validator.messages).to include("Parent entity for Comment:#{guid} is missing. "\
          "Impossible to import, ignoring.")
      end
    end
  end

  context "with a poll participation" do
    let(:relayable_entity) { :poll_participation_entity }

    context "with known root" do
      def create_root
        smwp = FactoryGirl.create(:status_message_with_poll)
        smwp.poll.update(guid: parent_guid)
      end

      include_examples "validation result is valid"
    end

    context "when root in unknown" do
      def create_root; end

      context "it fetches root" do
        before do
          expect(DiasporaFederation::Federation::Fetcher)
            .to receive(:fetch_public)
              .with(author.diaspora_handle, "Poll", parent_guid) {
                FactoryGirl.create(:poll, guid: parent_guid)
              }
        end

        include_examples "validation result is valid"
      end

      context "when root is in the archive and is an own post" do
        before do
          include_in_input_archive(
            user: {
              posts: [
                entity_data: {
                  text:       "123456",
                  created_at: "2017-07-03T08:12:25Z",
                  photos:     [],
                  author:     author_id,
                  public:     false,
                  guid:       "1234567890abcdef",
                  poll:       {
                    entity_type: "poll",
                    entity_data: {
                      guid:         parent_guid,
                      question:     "1234567 ?",
                      poll_answers: []
                    }
                  }
                },
                entity_type: "status_message"
              ]
            }
          )

          expect(DiasporaFederation::Federation::Fetcher)
            .not_to receive(:fetch_public)
        end

        include_examples "validation result is valid"
      end

      context "when fetching fails" do
        before do
          expect(DiasporaFederation::Federation::Fetcher)
            .to receive(:fetch_public)
            .with(author.diaspora_handle, "Poll", parent_guid)
            .and_raise(DiasporaFederation::Federation::Fetcher::NotFetchable)
        end

        it "is not valid and contains a message" do
          expect(validator.valid?).to be_falsey
          expect(validator.messages).to include("Parent entity for PollParticipation:#{guid} is missing. "\
          "Impossible to import, ignoring.")
        end
      end
    end
  end
end
