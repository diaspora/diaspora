
require File.dirname(__FILE__) + '/spec_helper'

module ActionView
  module Helpers
    module AssetTagHelper
      STYLESHEETS_DIR = "stylesheets"
    end
  end
end

describe MobilizedStyles do
  
  before(:each) do
    @view = mock(:ActionView)
    @request = mock(:ActionRequest)
    @view.extend(MobilizedStyles)
    @view.stub!(:request).and_return(@request)
    @request.stub!(:user_agent)
  end
  
  def ua(str)
    @request.stub!(:user_agent).and_return(str)
  end
  
  it "will include a mobilized css file if it recognizes a string in the user agent" do
    ua "iphone"
    File.should_receive(:exist?).with("stylesheets/style_iphone.css").and_return(true)
    @view.should_receive(:stylesheet_link_tag_without_mobilization).with("style", "style_iphone")
    @view.stylesheet_link_tag_with_mobilization("style")
  end
  
  it "includes mobiziled css files whether or not the original call to stylesheet_link_tag used a file extension" do
    ua "blackberry"
    File.should_receive(:exist?).with("stylesheets/style_blackberry.css").and_return(true)
    @view.should_receive(:stylesheet_link_tag_without_mobilization).with("style.css", "style_blackberry")
    @view.stylesheet_link_tag_with_mobilization("style.css")
  end
end