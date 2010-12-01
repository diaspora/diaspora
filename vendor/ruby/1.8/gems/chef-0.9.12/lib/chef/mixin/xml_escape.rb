#--
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# Copyright:: Copyright (c) 2005 Sam Ruby
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#--
# Portions of this code are adapted from Sam Ruby's xchar.rb
# http://intertwingly.net/stories/2005/09/28/xchar.rb 
#
# Such code appears here under Sam's original MIT license, while portions of
# this file are covered by the above Apache License.  For a completely MIT
# licensed version, please see Sam's original.
#
# Thanks, Sam!
# 
# Copyright (c) 2005, Sam Ruby 
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'chef/log'

begin
  require 'fast_xs'
rescue LoadError
  Chef::Log.info "The fast_xs gem is not installed, slower pure ruby XML escaping will be used."
end

class Chef
  module Mixin
    module XMLEscape

      module PureRuby
        extend self

        CP1252 = {
          128 => 8364, # euro sign
          130 => 8218, # single low-9 quotation mark
          131 =>  402, # latin small letter f with hook
          132 => 8222, # double low-9 quotation mark
          133 => 8230, # horizontal ellipsis
          134 => 8224, # dagger
          135 => 8225, # double dagger
          136 =>  710, # modifier letter circumflex accent
          137 => 8240, # per mille sign
          138 =>  352, # latin capital letter s with caron
          139 => 8249, # single left-pointing angle quotation mark
          140 =>  338, # latin capital ligature oe
          142 =>  381, # latin capital letter z with caron
          145 => 8216, # left single quotation mark
          146 => 8217, # right single quotation mark
          147 => 8220, # left double quotation mark
          148 => 8221, # right double quotation mark
          149 => 8226, # bullet
          150 => 8211, # en dash
          151 => 8212, # em dash
          152 =>  732, # small tilde
          153 => 8482, # trade mark sign
          154 =>  353, # latin small letter s with caron
          155 => 8250, # single right-pointing angle quotation mark
          156 =>  339, # latin small ligature oe
          158 =>  382, # latin small letter z with caron
          159 =>  376 # latin capital letter y with diaeresis
        }

        # http://www.w3.org/TR/REC-xml/#dt-chardata
        PREDEFINED = {
          38 => '&amp;', # ampersand
          60 => '&lt;',  # left angle bracket
          62 => '&gt;'  # right angle bracket
        }

        # http://www.w3.org/TR/REC-xml/#charsets
        VALID = [[0x9, 0xA, 0xD], (0x20..0xD7FF), 
          (0xE000..0xFFFD), (0x10000..0x10FFFF)]

        def xml_escape(unescaped_str)
          begin
            unescaped_str.unpack("U*").map {|char| xml_escape_char!(char)}.join
          rescue
            unescaped_str.unpack("C*").map {|char| xml_escape_char!(char)}.join
          end
        end

        private

        def xml_escape_char!(char)
          char = CP1252[char] || char
          char = 42 unless VALID.detect {|range| range.include? char}
          char = PREDEFINED[char] || (char<128 ? char.chr : "&##{char};")
        end
      end
      
      module FastXS
        extend self

        def xml_escape(string)
          string.fast_xs
        end

      end

      if "strings".respond_to?(:fast_xs)
        include FastXS
        extend FastXS
      else
        include PureRuby
        extend PureRuby
      end
    end
  end
end
