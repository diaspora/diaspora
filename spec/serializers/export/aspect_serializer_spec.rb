# frozen_string_literal: true

describe Export::AspectSerializer do
  let(:aspect) { FactoryGirl.create(:aspect) }
  let(:serializer) { Export::AspectSerializer.new(aspect) }

  it "has aspect attributes" do
    expect(serializer.attributes).to eq(
      name:             aspect.name,
      contacts_visible: aspect.contacts_visible,
      chat_enabled:     aspect.chat_enabled
    )
  end
end
