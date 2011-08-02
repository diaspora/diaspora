# Copyright (c) 2004-2008 David Heinemeier Hansson
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'yaml'
require 'strscan'

module Crack
  class JSON
    def self.parse(json)
      YAML.load(unescape(convert_json_to_yaml(json)))
    rescue ArgumentError => e
      raise ParseError, "Invalid JSON string"
    end

    protected
      def self.unescape(str)
        str.gsub(/\\u([0-9a-f]{4})/) { [$1.hex].pack("U") }
      end
      
      # matches YAML-formatted dates
      DATE_REGEX = /^\d{4}-\d{2}-\d{2}$|^\d{4}-\d{1,2}-\d{1,2}[T \t]+\d{1,2}:\d{2}:\d{2}(\.[0-9]*)?(([ \t]*)Z|[-+]\d{2}?(:\d{2})?)?$/

      # Ensure that ":" and "," are always followed by a space
      def self.convert_json_to_yaml(json) #:nodoc:
        scanner, quoting, marks, pos, times = StringScanner.new(json), false, [], nil, []
        while scanner.scan_until(/(\\['"]|['":,\\]|\\.)/)
          case char = scanner[1]
          when '"', "'"
            if !quoting
              quoting = char
              pos = scanner.pos
            elsif quoting == char
              if json[pos..scanner.pos-2] =~ DATE_REGEX
                # found a date, track the exact positions of the quotes so we can remove them later.
                # oh, and increment them for each current mark, each one is an extra padded space that bumps
                # the position in the final YAML output
                total_marks = marks.size
                times << pos+total_marks << scanner.pos+total_marks
              end
              quoting = false
            end
          when ":",","
            marks << scanner.pos - 1 unless quoting
          when "\\"
            scanner.skip(/\\/)
          end          
        end

        if marks.empty?
          json.gsub(/\\\//, '/')
        else
          left_pos  = [-1].push(*marks)
          right_pos = marks << json.length
          output    = []
          left_pos.each_with_index do |left, i|
            output << json[left.succ..right_pos[i]]
          end
          output = output * " "

          times.each { |i| output[i-1] = ' ' }
          output.gsub!(/\\\//, '/')
          output
        end
      end
  end
end
