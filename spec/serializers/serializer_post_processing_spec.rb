# frozen_string_literal: true

describe SerializerPostProcessing do
  describe "#modify_serializable_object" do
    it "allows to modify serializable object of ActiveModel::Serializer ancestor" do
      class TestSerializer < ActiveModel::Serializer
        include SerializerPostProcessing

        def modify_serializable_object(*)
          {
            custom_key: "custom_value"
          }
        end
      end

      serializer = TestSerializer.new({}, root: false)
      expect(serializer).to receive(:modify_serializable_object).and_call_original
      expect(serializer.to_json).to eq("{\"custom_key\":\"custom_value\"}")
    end
  end

  describe "#except" do
    it "allows to except a key from attributes" do
      class TestSerializer2 < ActiveModel::Serializer
        include SerializerPostProcessing

        attributes :key_to_exclude
      end

      serializer = TestSerializer2.new({}, root: false)
      serializer.except = [:key_to_exclude]
      expect(serializer.to_json).to eq("{}")
    end
  end
end
