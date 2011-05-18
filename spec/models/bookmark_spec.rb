#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Bookmark do
  describe '.from_activity' do
    before do
      @json = {
        "verb"=>"save",
        "target"=> {
          "url"=>"http://abcnews.go.com/US/wireStory?id=13630884",
          "objectType"=>"photo",
          "image"=> {
            "url"=>  "http://a.abcnews.com/images/Entertainment/abc_ann_wtb_blake_leo_110518_wl.jpg",
            "height"=>"112",
            "width"=>"200"
          }
        },
        "object"=> {
          "url"=>"cubbi.es/daniel",
          "objectType"=>"bookmark"
        }
      }
    end
    it 'marshals into a bookmark' do
      bookmark = Bookmark.from_activity(@json)
      bookmark.image_url.should == @json["target"]["image"]["url"]
      bookmark.image_height.should == @json["target"]["image"]["height"].to_i
      bookmark.image_width.should == @json["target"]["image"]["width"].to_i
      bookmark.target_url.should == @json["target"]["url"]
    end

  end
end
