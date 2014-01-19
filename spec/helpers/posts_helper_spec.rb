#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsHelper do

  describe '#post_page_title' do
    before do
      @sm = FactoryGirl.create(:status_message)
    end

    context 'with posts with text' do
      context 'when :length is passed in parameters' do
        it 'returns string of size less or equal to :length' do
          @sm = double(:text => "## My title\n Post content...")
          string_size = 12
          post_page_title(@sm, :length => string_size ).size.should <= string_size
        end
      end
      context 'when :length is not passed in parameters' do
        context 'with a Markdown header of less than 200 characters on first line'do
          it 'returns atx style header' do
            @sm = double(:text => "## My title\n Post content...")
            post_page_title(@sm).should == "## My title"
          end
          it 'returns setext style header' do
            @sm = double(:text => "My title \n======\n Post content...")
            post_page_title(@sm).should ==  "My title \n======"
          end
        end
        context 'without a Markdown header of less than 200 characters on first line 'do
          it 'truncates posts to the 20 first characters' do
            @sm = double(:text => "Very, very, very long post")
            post_page_title(@sm).should == "Very, very, very ..."
          end
        end
      end
    end
  end


  describe '#post_iframe_url' do
    before do
      @post = FactoryGirl.create(:status_message)
    end

    it "returns an iframe tag" do
      post_iframe_url(@post.id).should include "iframe"
    end

    it "returns an iframe containing the post" do
      post_iframe_url(@post.id).should include "src='http://localhost:9887#{post_path(@post)}'"
    end
  end
end
