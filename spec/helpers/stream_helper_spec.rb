#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamHelper do
  describe "next_page_path" do
    before do
      @stream = Stream::Base.new(alice, :max_time => Time.now)
    end
      it 'works for public page' do
        stub!(:controller).and_return(PostsController.new)
        next_page_path.should include '/public'
      end

      it 'works for stream page when current page is stream' do
        self.stub!("current_page?").and_return(true)
        stub!(:controller).and_return(StreamsController.new)
        next_page_path.should include stream_path
      end

      it 'works for activity page when current page is not stream' do
        self.stub!("current_page?").and_return(false)
        stub!(:controller).and_return(StreamsController.new)
        next_page_path.should include activity_stream_path
      end
  end
end
