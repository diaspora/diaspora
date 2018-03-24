# frozen_string_literal: true

require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Public do
  before do
    @stream = Stream::Public.new(alice)
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe "#posts" do
    it "calls Post#all_public" do
      expect(Post).to receive(:all_public)
      @stream.posts
    end
  end
end
