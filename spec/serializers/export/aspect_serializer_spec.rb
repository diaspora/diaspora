# frozen_string_literal: true

describe Export::AspectSerializer do
  let(:aspect) { FactoryGirl.create(:aspect) }
  let(:serializer) { Export::AspectSerializer.new(aspect) }

  it "has aspect attributes" do
    expect(serializer.attributes).to eq(
      name: aspect.name
    )
  end
end
