# frozen_string_literal: true

describe Export::OwnRelayablesSerializer do
  let(:comment) { FactoryGirl.create(:comment) }
  let!(:signature) { FactoryGirl.create(:comment_signature, comment: comment) }
  let(:instance) { Export::OwnRelayablesSerializer.new(comment, root: false) }

  it "doesn't include author signature to the entity data" do
    expect(JSON.parse(instance.to_json)["entity_data"]).not_to have_key("author_signature")
  end
end
