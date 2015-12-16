#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamHelper, :type => :helper do
  describe "next_page_path" do
    def build_controller controller_class
      controller_class.new.tap {|c| c.request = controller.request }
    end
    before do
      @stream = Stream::Base.new(alice, :max_time => Time.now)
    end

    it 'works for public page' do
      allow(helper).to receive(:controller).and_return(build_controller(PostsController))
      expect(helper.next_page_path).to include '/public'
    end

    it 'works for stream page when current page is stream' do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include stream_path
    end

    it 'works for aspects page when current page is aspects' do
      allow(helper).to receive(:current_page?).and_return(false)
      expect(helper).to receive(:current_page?).with(:aspects_stream).and_return(true)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      expect(helper.next_page_path).to include aspects_stream_path
    end

    it 'works for activity page when current page is not stream or aspects' do
      allow(helper).to receive(:current_page?).and_return(false)
      allow(helper).to receive(:controller).and_return(build_controller(StreamsController))
      # binding.pry
      expect(helper.next_page_path).to include activity_stream_path
    end
  end
end
