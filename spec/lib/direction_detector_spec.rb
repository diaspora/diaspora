# coding: utf-8
# Copyright (c) 2010, Diaspora Inc.  This file is
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
      english.starts_with_rtl_char?.should be_false
      chinese.starts_with_rtl_char?.should be_false
      arabic.starts_with_rtl_char?.should be_true
      hebrew.starts_with_rtl_char?.should be_true
      hebrew_arabic.starts_with_rtl_char?.should be_true
    end

    it 'only looks at the first char' do
      english_chinese.starts_with_rtl_char?.should be_false
      chinese_english.starts_with_rtl_char?.should be_false
      english_arabic.starts_with_rtl_char?.should be_false
      hebrew_english.starts_with_rtl_char?.should be_true
      arabic_chinese.starts_with_rtl_char?.should be_true
    end
    
    it 'ignores whitespaces' do
      " \n \r \t".starts_with_rtl_char?.should be_false
      " #{arabic} ".starts_with_rtl_char?.should be_true
    end
  end

  describe "#is_rtl?" do
    it 'returns true or false correctly' do
      english.is_rtl?.should be_false
      chinese.is_rtl?.should be_false
      arabic.is_rtl?.should be_true
      hebrew.is_rtl?.should be_true
    end

    it 'respects all words' do
      chinese_arabic.is_rtl?.should be_true
      chinese_hebrew.is_rtl?.should be_true
      english_hebrew.is_rtl?.should be_false
      hebrew_arabic.is_rtl?.should be_true
      "#{english} #{arabic} #{chinese}".is_rtl?.should be_false
      "Translated to arabic, Hello World means: #{arabic}".is_rtl?.should be_false
      "#{english} #{arabic} #{arabic}".is_rtl?.should be_true
    end

    it "fallbacks to the first word if there's no majority" do
      hebrew_english.is_rtl?.should be_true
      english_hebrew.is_rtl?.should be_false
      arabic_english.is_rtl?.should be_true
      english_arabic.is_rtl?.should be_false
    end

    it 'ignores whitespaces' do
      " \n \r \t".is_rtl?.should be_false
      " #{arabic} ".is_rtl?.should be_true
    end
  end

  describe '#cleaned_is_rtl?' do
    it 'should clean the string' do
      "RT: #{arabic}".cleaned_is_rtl?.should be_true
      "#{hebrew} RT: #{arabic}".cleaned_is_rtl?.should be_true
      "@foo #{arabic}".cleaned_is_rtl?.should be_true 
      "#{hebrew} #example".cleaned_is_rtl?.should be_true 
      "♺: #{arabic} ♻: #{hebrew}".cleaned_is_rtl?.should be_true 
    end
  end
end
