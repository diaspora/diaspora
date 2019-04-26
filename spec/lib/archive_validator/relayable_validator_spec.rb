# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::RelayableValidator do
  include_context "validators shared context"
  include_context "relayable validator context"

  let(:author) { FactoryGirl.create(:user).person }

  context "with comment" do
    let(:relayable_entity) { :comment_entity }

    context "when parent is in the archive" do
      before do
        include_in_input_archive(
          user: {
            posts: [
              {
                "entity_type"          => "status_message",
                "subscribed_users_ids" => [],
                "entity_data"          => {
                  "text"   => "test",
                  "author" => "test@example.com",
                  "public" => false,
                  "guid"   => parent_guid
                }
              }
            ]
          }
        )
      end

      it_behaves_like "a relayable validator"
    end

    context "when parent is not in the archive" do
      it "is not valid" do
        expect(validator.valid?).to be_falsey
        expect(validator.messages).to eq(
          ["Parent entity for Comment:#{guid} is missing. Impossible to import, ignoring."]
        )
      end
    end
  end

  context "with poll participation" do
    let(:relayable_entity) { :poll_participation_entity }

    context "when parent is in the archive" do
      before do
        include_in_input_archive(
          user: {
            posts: [
              {
                "entity_type"          => "status_message",
                "subscribed_users_ids" => [],
                "entity_data"          => {
                  "text"   => "test",
                  "author" => "test@example.com",
                  "public" => false,
                  "guid"   => "abcdef1234567890abcdef1234567890",
                  "poll"   => {
                    "entity_type" => "poll",
                    "entity_data" => {
                      "guid"         => parent_guid,
                      "question"     => "question text?",
                      "poll_answers" => [{
                        "entity_type" => "poll_answer",
                        "entity_data" => {
                          "guid"   => "abcdef1234567890abcdef1234567891",
                          "answer" => "answer text"
                        }
                      }]
                    }
                  }
                }
              }
            ]
          }
        )
      end

      it_behaves_like "a relayable validator"
    end

    context "when parent is not in the archive" do
      it "is not valid" do
        expect(validator.valid?).to be_falsey
        expect(validator.messages).to eq(
          ["Parent entity for PollParticipation:#{guid} is missing. Impossible to import, ignoring."]
        )
      end
    end
  end
end
