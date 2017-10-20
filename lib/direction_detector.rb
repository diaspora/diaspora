# coding: utf-8
# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class String
  RTL_CLEANER_REGEXES = [ /@[^ ]+|#[^ ]+/u, # mention, tag
      /^RT[: ]{1}| RT | RT: |[♺♻:]/u # retweet
    ]

  def is_rtl?
    return false if self.strip.empty?
    detector = StringDirection::Detector.new(:dominant)
    detector.rtl? self
  end

  # Diaspora specific
  def cleaned_is_rtl?
    string = String.new(self)
    RTL_CLEANER_REGEXES.each do |cleaner|
      string.gsub!(cleaner, '')
    end
    string.is_rtl?
  end
end
