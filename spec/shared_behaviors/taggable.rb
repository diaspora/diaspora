# coding: utf-8
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Taggable do
  shared_examples_for "it is taggable" do
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers
    def controller
    end

    describe '.format_tags' do
      before do
        @str = '#what #hey #vöglein'
        @object.send(@object.class.field_with_tags_setter, @str)
        @object.build_tags
        @object.save!
      end

      it 'links the tag to /p' do
        link = link_to('#vöglein', '/tags/vöglein', :class => 'tag')
        Diaspora::Taggable.format_tags(@str).should include(link)
      end

      it 'responds to plain_text' do
        Diaspora::Taggable.format_tags(@str, :plain_text => true).should == @str
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
        str = '#what #hey #that"smybike. #@hey ##boo # #THATWASMYBIKE #vöglein #hey#there #135440we #abc/23 ### #h!gh #ok? #see: #re:publica'
        arr = ['what', 'hey', 'that', 'THATWASMYBIKE', 'vöglein', '135440we', 'abc', 'h', 'ok', 'see', 're']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end

      it 'extracts tags despite surrounding text' do
        expected = {
          '#foobar'                => 'foobar',
          '#foocar<br>'            => 'foocar',
          '#fooo@oo'               => 'fooo',
          '#num3ric hash tags'     => 'num3ric',
          '#12345 tag'             => '12345',
          '#12cde tag'             => '12cde',
          '#abc45 tag'             => 'abc45',
          '#<3'                    => '<3',
          '#<4'                    => nil,
          'test#foo test'          => nil,
          'test.#joo bar'          => nil,
          'test #foodar test'      => 'foodar',
          'test #foofar<br> test ' => 'foofar',
          'test #gooo@oo test'     => 'gooo',
          'test #<3 test'          => '<3',
          'test #foo-test test'    => 'foo-test',
          'test #hoo'              => 'hoo',
          'test #two_word tags'    => 'two_word',
          'test #three_word_tags'  => 'three_word_tags',
          '#terminal_underscore_'  => 'terminal_underscore_',
          '#terminalunderscore_'   => 'terminalunderscore_',
          '#_initialunderscore'    => '_initialunderscore',
          '#_initial_underscore'   => '_initial_underscore',
          '#terminalhyphen-'       => 'terminalhyphen-',
          '#terminal-hyphen-'      => 'terminal-hyphen-',
          '#terminalhyphen- tag'   => 'terminalhyphen-',
          '#-initialhyphen'        => '-initialhyphen',
          '#-initialhyphen tag'    => '-initialhyphen',
          '#-initial-hyphen'       => '-initial-hyphen',
        }

        expected.each do |text,hashtag|
          @object.send  @object.class.field_with_tags_setter, text
          @object.tag_strings.should == [hashtag].compact
        end
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

