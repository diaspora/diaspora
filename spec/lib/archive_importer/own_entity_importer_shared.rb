# frozen_string_literal: true

shared_examples "own entity importer" do
  describe "#import" do
    let(:new_user) { FactoryGirl.create(:user) }
    let(:instance) { described_class.new(entity_json.as_json, new_user) }

    context "with known entity" do
      context "with correct author in json" do
        let(:entity_json) { known_entity_with_correct_author }

        it "doesn't import" do
          expect {
            instance.import
          }.not_to change(entity_class, :count)
        end
      end

      context "with incorrect author in json" do
        let(:entity_json) { known_entity_with_incorrect_author }

        it "doesn't import" do
          expect {
            instance.import
          }.not_to change(entity_class, :count)
        end
      end
    end

    context "with unknown entity" do
      let(:guid) { unknown_entity[:entity_data][:guid] }
      let(:entity_json) { unknown_entity }

      it "imports with author substitution" do
        expect {
          instance.import
        }.to change(entity_class, :count).by(1)

        status_message = entity_class.find_by(guid: guid)
        expect(status_message.author).to eq(new_user.person)
      end
    end
  end
end
