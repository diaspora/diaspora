# frozen_string_literal: true

describe InterimStreamHackinessHelper, type: :helper do
  describe "#publisher_formatted_text" do
    it "returns the prefill text from the stream" do
      @stream = double(publisher: Publisher.new(alice, prefill: "hello world"))
      expect(publisher_formatted_text).to eq("hello world")
    end
  end
end
