# frozen_string_literal: true

describe FederationEntitySerializer do
  class TestEntity < DiasporaFederation::Entity
    property :test, :string
  end

  let(:object) { double }

  before do
    # Mock a builder for a TestEntity that we define for this test
    allow(Diaspora::Federation::Mappings).to receive(:builder_for).with(object.class).and_return(:test_entity)
    allow(Diaspora::Federation::Entities).to receive(:test_entity).with(object) {
      TestEntity.new(test: "asdf")
    }
  end

  it_behaves_like "a federation entity serializer"
end
