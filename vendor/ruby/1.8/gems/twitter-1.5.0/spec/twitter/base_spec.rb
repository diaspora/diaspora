require 'helper'

describe Twitter::Base do
  context ".new" do
    before do
      @client = Twitter::Base.new
    end

    describe ".home_timeline" do

      before do
        stub_get("statuses/home_timeline.json").
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.home_timeline
        a_get("statuses/home_timeline.json").
          should have_been_made
      end
    end
  end
end
