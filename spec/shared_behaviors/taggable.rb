#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Taggable do
  shared_examples_for "it is taggable" do
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers
    def controller
    end

    describe '#format_tags' do
      before do
        @str = '#what #hey'
        @object.send(@object.class.field_with_tags_setter, @str)
        @object.build_tags
        @object.save!
      end
      it 'links the tag to /p' do
        link = link_to('#what', posts_path(:tag => 'what'), :class => 'tag')
        @object.format_tags(@str).should include(link)
      end
      it 'responds to plain_text' do
        @object.format_tags(@str, :plain_text => true).should == @str
      end
    end
    describe '#build_tags' do
      it 'builds the tags' do
        @object.send(@object.class.field_with_tags_setter, '#what')
        @object.build_tags
        @object.tag_list.should == ['what']
        lambda {
          @object.save
        }.should change{@object.tags.count}.by(1)
      end
    end
    describe '#tag_strings' do
      it 'returns a string for every #thing' do
        str = '#what #hey #that"smybike. #@hey ##boo # #THATWASMYBIKE #hey#there #135440we #abc/23 ###'
        arr = ['what', 'hey', 'that', 'THATWASMYBIKE', '135440we', 'abc']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end
      it 'returns no duplicates' do
        str = '#what #what #what #whaaaaaaaaaat'
        arr = ['what','whaaaaaaaaaat']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end
      it 'is case insensitive' do
        str = '#what #wHaT #WHAT'
        arr = ['what']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end
    end
  end
end

