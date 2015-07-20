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
      expect(english.starts_with_rtl_char?).to be false
      expect(chinese.starts_with_rtl_char?).to be false
      expect(arabic.starts_with_rtl_char?).to be true
      expect(hebrew.starts_with_rtl_char?).to be true
      expect(hebrew_arabic.starts_with_rtl_char?).to be true
    end

    it 'only looks at the first char' do
      expect(english_chinese.starts_with_rtl_char?).to be false
      expect(chinese_english.starts_with_rtl_char?).to be false
      expect(english_arabic.starts_with_rtl_char?).to be false
      expect(hebrew_english.starts_with_rtl_char?).to be true
      expect(arabic_chinese.starts_with_rtl_char?).to be true
    end
    
    it 'ignores whitespaces' do
      expect(" \n \r \t".starts_with_rtl_char?).to be false
      expect(" #{arabic} ".starts_with_rtl_char?).to be true
    end
  end

  describe "#is_rtl?" do
    it 'returns true or false correctly' do
      expect(english.is_rtl?).to be false
      expect(chinese.is_rtl?).to be false
      expect(arabic.is_rtl?).to be true
      expect(hebrew.is_rtl?).to be true
    end

    it 'respects all words' do
      expect(chinese_arabic.is_rtl?).to be true
      expect(chinese_hebrew.is_rtl?).to be true
      expect(english_hebrew.is_rtl?).to be false
      expect(hebrew_arabic.is_rtl?).to be true
      expect("#{english} #{arabic} #{chinese}".is_rtl?).to be false
      expect("Translated to arabic, Hello World means: #{arabic}".is_rtl?).to be false
      expect("#{english} #{arabic} #{arabic}".is_rtl?).to be true
    end

    it "fallbacks to the first word if there's no majority" do
      expect(hebrew_english.is_rtl?).to be true
      expect(english_hebrew.is_rtl?).to be false
      expect(arabic_english.is_rtl?).to be true
      expect(english_arabic.is_rtl?).to be false
    end

    it 'ignores whitespaces' do
      expect(" \n \r \t".is_rtl?).to be false
      expect(" #{arabic} ".is_rtl?).to be true
    end
  end

  describe '#cleaned_is_rtl?' do
    it 'should clean the string' do
      expect("RT: #{arabic}".cleaned_is_rtl?).to be true
      expect("#{hebrew} RT: #{arabic}".cleaned_is_rtl?).to be true
      expect("@foo #{arabic}".cleaned_is_rtl?).to be true
      expect("#{hebrew} #example".cleaned_is_rtl?).to be true
      expect("♺: #{arabic} ♻: #{hebrew}".cleaned_is_rtl?).to be true
    end
  end
end
