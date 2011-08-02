#!/usr/local/bin/ruby -w

# tc_encodings.rb
#
#  Created by Michael Reinsch.
#  Copyright (c) 2008 Ubiquitous Business Technology, Inc.

require "test/unit"

require "faster_csv"

class TestEncodings < Test::Unit::TestCase
  def test_with_shift_jis_encoding
    $KCODE = 'u'  # make sure $KCODE != Shift_JIS
    # this test data will not work with UTF-8 encoding
    shift_jis_data = [ "82D082E782AA82C82094E0",
                       "82D082E7826082AA825C",
                       "82D082E7826082AA82C8" ].map { |f| [f].pack("H*") }
    fields = FCSV.parse_line( shift_jis_data.map { |f| %Q{"#{f}"} }.join(","),
                              :encoding => "s" )
    assert_equal(shift_jis_data, fields)
  end
end
