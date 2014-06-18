#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamHelper do
  describe "next_page_path" do
    def build_controller controller_class
      controller_class.new.tap {|c| c.request = controller.request }
    end
    before do
      @stream = Stream::Base.new(alice, :max_time => Time.now)
    end

    it 'works for public page' do
      helper.stub(:controller).and_return(build_controller(PostsController))
      helper.next_page_path.should include '/public'
    end

    it 'works for stream page when current page is stream' do
      helper.stub(:current_page?).and_return(false)
      helper.should_receive(:current_page?).with(:stream).and_return(true)
      helper.stub(:controller).and_return(build_controller(StreamsController))
      helper.next_page_path.should include stream_path
    end

    it 'works for aspects page when current page is aspects' do
      helper.stub(:current_page?).and_return(false)
      helper.should_receive(:current_page?).with(:aspects_stream).and_return(true)
      helper.stub(:controller).and_return(build_controller(StreamsController))
      helper.next_page_path.should include aspects_stream_path
    end

    it 'works for activity page when current page is not stream or aspects' do
      helper.stub(:current_page?).and_return(false)
      helper.stub(:controller).and_return(build_controller(StreamsController))
      # binding.pry
      helper.next_page_path.should include activity_stream_path
    end
  end
end
