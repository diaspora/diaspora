# coding: utf-8
# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'

describe String do
  let(:english) { "Hello World" }
  let(:chinese) { "你好世界" }
  let(:arabic) { "مرحبا العالم" }
  let(:hebrew) { "שלום העולם" }
  let(:english_chinese) { "#{english} #{chinese}" }
  let(:english_arabic) { "#{english} #{chinese}" }
  let(:english_hebrew) { "#{english} #{chinese}" }
  let(:chinese_english) { "#{chinese} #{english}" }
  let(:chinese_arabic) { "#{chinese} #{arabic}" }
  let(:chinese_hebrew) { "#{chinese} #{hebrew}" }
  let(:arabic_english) { "#{arabic} #{english}" }
  let(:arabic_chinese) { "#{arabic} #{chinese}" }
  let(:arabic_hebrew) { "#{arabic} #{hebrew}" }
  let(:hebrew_english) { "#{hebrew} #{english}" }
  let(:hebrew_chinese) { "#{hebrew} #{chinese}" }
  let(:hebrew_arabic) { "#{hebrew} #{arabic}" }


  describe "#stats_with_rtl_char?" do
    it 'returns true or false correctly' do
      english.starts_with_rtl_char?.should be false
      chinese.starts_with_rtl_char?.should be false
      arabic.starts_with_rtl_char?.should be true
      hebrew.starts_with_rtl_char?.should be true
      hebrew_arabic.starts_with_rtl_char?.should be true
    end

    it 'only looks at the first char' do
      english_chinese.starts_with_rtl_char?.should be false
      chinese_english.starts_with_rtl_char?.should be false
      english_arabic.starts_with_rtl_char?.should be false
      hebrew_english.starts_with_rtl_char?.should be true
      arabic_chinese.starts_with_rtl_char?.should be true
    end
    
    it 'ignores whitespaces' do
      " \n \r \t".starts_with_rtl_char?.should be false
      " #{arabic} ".starts_with_rtl_char?.should be true
    end
  end

  describe "#is_rtl?" do
    it 'returns true or false correctly' do
      english.is_rtl?.should be false
      chinese.is_rtl?.should be false
      arabic.is_rtl?.should be true
      hebrew.is_rtl?.should be true
    end

    it 'respects all words' do
      chinese_arabic.is_rtl?.should be true
      chinese_hebrew.is_rtl?.should be true
      english_hebrew.is_rtl?.should be false
      hebrew_arabic.is_rtl?.should be true
      "#{english} #{arabic} #{chinese}".is_rtl?.should be false
      "Translated to arabic, Hello World means: #{arabic}".is_rtl?.should be false
      "#{english} #{arabic} #{arabic}".is_rtl?.should be true
    end

    it "fallbacks to the first word if there's no majority" do
      hebrew_english.is_rtl?.should be true
      english_hebrew.is_rtl?.should be false
      arabic_english.is_rtl?.should be true
      english_arabic.is_rtl?.should be false
    end

    it 'ignores whitespaces' do
      " \n \r \t".is_rtl?.should be false
      " #{arabic} ".is_rtl?.should be true
    end
  end

  describe '#cleaned_is_rtl?' do
    it 'should clean the string' do
      "RT: #{arabic}".cleaned_is_rtl?.should be true
      "#{hebrew} RT: #{arabic}".cleaned_is_rtl?.should be true
      "@foo #{arabic}".cleaned_is_rtl?.should be true
      "#{hebrew} #example".cleaned_is_rtl?.should be true
      "♺: #{arabic} ♻: #{hebrew}".cleaned_is_rtl?.should be true
    end
  end
end
