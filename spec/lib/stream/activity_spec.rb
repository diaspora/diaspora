require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')

describe Stream::Activity do
  before do
    @stream = Stream::Activity.new(alice, :max_time => Time.now, :order => 'updated_at')
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe "participations with the same timestamp" do
    before do
      @status_msgZ = Factory(:status_message, :author => bob.person)
      @status_msgY = Factory(:status_message, :author => bob.person)
      @status_msgX = Factory(:activity_streams_photo, :author => bob.person)

      Timecop.freeze do
        alice.like!(@status_msgY)
        alice.comment!(@status_msgZ, "party")
        alice.like!(@status_msgX)
      end
    end

    let(:posts) { Stream::Activity.new(alice).stream_posts }

    it "returns the posts in the reverse order they were interacted with" do
      posts.map(&:id).should == [@status_msgX.id, @status_msgZ.id, @status_msgY.id]
    end
  end
end
