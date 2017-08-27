# frozen_string_literal: true

shared_examples_for "a federation entity serializer" do
  describe "#to_json" do
    it "contains JSON serialized entity object" do
      entity = nil
      expect(Diaspora::Federation::Entities).to receive(:build)
        .with(object)
        .and_wrap_original do |original, object, &block|
        entity = original.call(object, &block)
      end
      json = described_class.new(object, root: false).to_json
      expect(json).to include_json(entity.to_json)
    end
  end
end
