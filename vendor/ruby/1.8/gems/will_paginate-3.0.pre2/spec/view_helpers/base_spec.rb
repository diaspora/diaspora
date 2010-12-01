require 'spec_helper'
require 'will_paginate/view_helpers/base'
require 'will_paginate/array'

describe WillPaginate::ViewHelpers::Base do

  include WillPaginate::ViewHelpers::Base
  
  describe "will_paginate" do
    it "should render" do
      collection = WillPaginate::Collection.new(1, 2, 4)
      renderer   = mock 'Renderer'
      renderer.expects(:prepare).with(collection, instance_of(Hash), self)
      renderer.expects(:to_html).returns('<PAGES>')
      
      will_paginate(collection, :renderer => renderer).should == '<PAGES>'
    end
    
    it "should return nil for single-page collections" do
      collection = mock 'Collection', :total_pages => 1
      will_paginate(collection).should be_nil
    end
  end
  
  describe "page_entries_info" do
    before :all do
      @array = ('a'..'z').to_a
    end

    def info(params, options = {})
      options[:html] ||= false unless options.key?(:html) and options[:html].nil?
      collection = Hash === params ? @array.paginate(params) : params
      page_entries_info collection, options
    end

    it "should display middle results and total count" do
      info(:page => 2, :per_page => 5).should == "Displaying strings 6 - 10 of 26 in total"
    end

    it "should output HTML by default" do
      info({ :page => 2, :per_page => 5 }, :html => nil).should ==
        "Displaying strings <b>6&nbsp;-&nbsp;10</b> of <b>26</b> in total"
    end

    it "should display shortened end results" do
      info(:page => 7, :per_page => 4).should include_phrase('strings 25 - 26')
    end

    it "should handle longer class names" do
      collection = @array.paginate(:page => 2, :per_page => 5)
      collection.first.stubs(:class).returns(mock('Class', :name => 'ProjectType'))
      info(collection).should include_phrase('project types')
    end

    it "should adjust output for single-page collections" do
      info(('a'..'d').to_a.paginate(:page => 1, :per_page => 5)).should == "Displaying all 4 strings"
      info(['a'].paginate(:page => 1, :per_page => 5)).should == "Displaying 1 string"
    end
  
    it "should display 'no entries found' for empty collections" do
      info([].paginate(:page => 1, :per_page => 5)).should == "No entries found"
    end
  end
end
