# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe StreamHelper, type: :helper do
  describe "next_page_path" do
    def build_controller controller_class
      controller_class.new.tap {|c| c.request = controller.request }
    end
    before do
      @stream = Stream::Base.new(alice, :max_time => Time.now)
    end

    it "works for public page when current page is public stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:public_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include "/public"
    end

    it "works for stream page when current page is stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include stream_path
    end

    it "works for aspects page when current page is aspects" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:aspects_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include aspects_stream_path
    end

    it "works for activity page when current page is activity stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:activity_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include activity_stream_path
    end

    it "works for commented page when current page is commented stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:commented_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include commented_stream_path
    end

    it "works for liked page when current page is liked stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:liked_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include liked_stream_path
    end

    it "works for mentioned page when current page is mentioned stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:mentioned_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include mentioned_stream_path
    end

    it "works for followed tags page when current page is followed tags stream" do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:followed_tags_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include followed_tags_stream_path
    end
  end
end
