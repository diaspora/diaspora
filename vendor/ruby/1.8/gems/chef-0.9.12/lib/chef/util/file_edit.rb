#
# Author:: Nuo Yan (<nuo@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'fileutils'
require 'tempfile'

class Chef
  class Util
  	class FileEdit

  		private
  		
  		attr_accessor :original_pathname, :contents, :file_edited

  		public
  		
  		def initialize(filepath)
  			@original_pathname = filepath
  			@file_edited = false
  			
  			raise ArgumentError, "File doesn't exist" unless File.exist? @original_pathname
  			raise ArgumentError, "File is blank" unless (@contents = File.new(@original_pathname).readlines).length > 0
  		end
  		
  		#search the file line by line and match each line with the given regex
  		#if matched, replace the whole line with newline.
  		def search_file_replace_line(regex, newline)
  			search_match(regex, newline, 'r', 1)
  		end

  		#search the file line by line and match each line with the given regex
  		#if matched, replace the match (all occurances)  with the replace parameter
  		def search_file_replace(regex, replace)
  			search_match(regex, replace, 'r', 2)
  		end
  		
  		#search the file line by line and match each line with the given regex
  		#if matched, delete the line
  		def search_file_delete_line(regex)
  			search_match(regex, " ", 'd', 1)
  		end
  		
  		#search the file line by line and match each line with the given regex
  		#if matched, delete the match (all occurances) from the line
  		def search_file_delete(regex)
  			search_match(regex, " ", 'd', 2)
  		end

  		#search the file line by line and match each line with the given regex
  		#if matched, insert newline after each matching line
  		def insert_line_after_match(regex, newline)
  			search_match(regex, newline, 'i', 0)
  		end
  		 
  		#Make a copy of old_file and write new file out (only if file changed)
  		def write_file
  			
  			# file_edited is false when there was no match in the whole file and thus no contents have changed.
        if file_edited
          backup_pathname = original_pathname + ".old"
          FileUtils.cp(original_pathname, backup_pathname, :preserve => true)
          File.open(original_pathname, "w") do |newfile|
            contents.each do |line|
              newfile.puts(line)
            end
            newfile.flush
          end
        end
        self.file_edited = false
  		end
  		
  		private
  		
  		#helper method to do the match, replace, delete, and insert operations
  		#command is the switch of delete, replace, and insert ('d', 'r', 'i')
  		#method is to control operation on whole line or only the match (1 for line, 2 for match)
  		def search_match(regex, replace, command, method)
  			
  			#convert regex to a Regexp object (if not already is one) and store it in exp.
  			exp = Regexp.new(regex)

  			#loop through contents and do the appropriate operation depending on 'command' and 'method'
  			new_contents = []
  			
  			contents.each do |line|
  				if line.match(exp) 
  					self.file_edited = true
  					case
  					when command == 'r'
  						new_contents << ((method == 1) ? replace : line.gsub!(exp, replace))
  					when command == 'd'
  						if method == 2
  							new_contents << line.gsub!(exp, "")
  						end
  					when command == 'i'
  						new_contents << line
  						new_contents << replace
  					end
  				else
  					new_contents << line
  				end
  			end

  			self.contents = new_contents
  		end
  	end
  end
end
