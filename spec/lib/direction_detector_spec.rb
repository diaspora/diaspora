# coding: utf-8
# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

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

    it 'ignores whitespaces' do
      expect(" \n \r \t".is_rtl?).to be false
      expect(" #{arabic} ".is_rtl?).to be true
    end

    it "ignores byte order marks" do
      expect("\u{feff}".is_rtl?).to be false
      expect("\u{feff}#{arabic}".is_rtl?).to be true
      expect("\u{feff}#{english}".is_rtl?).to be false
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
