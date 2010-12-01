#--
# Copyright (c) 2005-2010 Philip Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++

# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


require 'tzinfo/ruby_core_support'
require 'tzinfo/offset_rationals'
require 'tzinfo/time_or_datetime'

require 'tzinfo/timezone_definition'

require 'tzinfo/timezone_offset_info'
require 'tzinfo/timezone_transition_info'

require 'tzinfo/timezone_index_definition'

require 'tzinfo/timezone_info'
require 'tzinfo/data_timezone_info'
require 'tzinfo/linked_timezone_info'

require 'tzinfo/timezone_period'
require 'tzinfo/timezone'
require 'tzinfo/info_timezone'
require 'tzinfo/data_timezone'
require 'tzinfo/linked_timezone'
require 'tzinfo/timezone_proxy'

require 'tzinfo/country_index_definition'
require 'tzinfo/country_info'

require 'tzinfo/country'
require 'tzinfo/country_timezone'
