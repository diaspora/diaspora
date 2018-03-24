# frozen_string_literal: true

require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Activity do
  before do
    @stream = Stream::Activity.new(alice)
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe "#posts" do
    it "calls EvilQuery::Participation with correct parameters" do
      expect(::EvilQuery::Participation).to receive(:new)
              .with(alice)
              .and_return(double.tap { |m| allow(m).to receive(:posts)})
      @stream.posts
    end
  end
end
