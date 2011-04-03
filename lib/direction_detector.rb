# coding: utf-8
#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
# Deeply inspired by https://gitorious.org/statusnet/mainline/blobs/master/plugins/DirectionDetector/DirectionDetectorPlugin.php

class String

  def is_rtl?
    return false if self.strip.empty?
    count = 0
    self.split(" ").each do |word|
      if starts_with_rtl_char?(word)
        count += 1
      else
        count -= 1
      end
    end
    return true if count > 0 # more than half of the words are rtl words
    return starts_with_rtl_char?(self) # otherwise let the first word decide
  end

  # Diaspora specific
  def cleaned_is_rtl?
    string = String.new(self)
    [ /@[^ ]+|#[^ ]+/u, # mention, tag
      /^RT[: ]{1}| RT | RT: |[♺♻:]/u # retweet
    ].each do |cleaner|
      string.gsub!(cleaner, '')
    end
    string.is_rtl?
  end

  def starts_with_rtl_char?(string = self)
    return false if string.strip.empty?
    char = string.strip.unpack('U*').first
    limits = [
      [1536, 1791], # arabic, persian, urdu, kurdish, ...
      [65136, 65279], # arabic peresent 2
      [64336, 65023], # arabic peresent 1
      [1424, 1535], # hebrew
      [64256, 64335], # hebrew peresent
      [1792, 1871], # syriac
      [1920, 1983], # thaana
      [1984, 2047], # nko
      [11568, 11647] # tifinagh
    ]
    limits.each do |limit|
      return true if char >= limit[0] && char <= limit[1]
    end
    return false
  end
end
