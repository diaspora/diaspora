#--
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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
#

require 'tempfile'
require 'erubis'

class Chef
  module Mixin
    module Template
      
      module ChefContext
        def node
          return @node if @node
          raise "Could not find a value for node. If you are explicitly setting variables in a template, " +
                "include a node variable if you plan to use it."
        end
      end
      
      ::Erubis::Context.send(:include, ChefContext)
      
      # Render a template with Erubis.  Takes a template as a string, and a 
      # context hash.  
      def render_template(template, context)
        begin
          eruby = Erubis::Eruby.new(template)
          output = eruby.evaluate(context)
        rescue Object => e
          raise TemplateError.new(e, template, context)
        end
        Tempfile.open("chef-rendered-template") do |tempfile|
          tempfile.print(output)
          tempfile.close
          yield tempfile
        end
      end
      
      class TemplateError < RuntimeError
        attr_reader :original_exception, :context
        SOURCE_CONTEXT_WINDOW = 2
        
        def initialize(original_exception, template, context)
          @original_exception, @template, @context = original_exception, template, context
        end
        
        def message
          @original_exception.message
        end
        
        def line_number
          @line_number ||= $1.to_i if original_exception.backtrace.find {|line| line =~ /\(erubis\):(\d+)/ }
        end
        
        def source_location
          "on line ##{line_number}"
        end
        
        def source_listing
          @source_listing ||= begin
            line_index = line_number - 1
            beginning_line = line_index <= SOURCE_CONTEXT_WINDOW ? 0 : line_index - SOURCE_CONTEXT_WINDOW
            source_size = SOURCE_CONTEXT_WINDOW * 2 + 1
            lines = @template.split(/\n/)
            contextual_lines = lines[beginning_line, source_size]
            output = []
            contextual_lines.each_with_index do |line, index|
              line_number = (index+beginning_line+1).to_s.rjust(3)
              output << "#{line_number}: #{line}"
            end
            output.join("\n")
          end
        end
        
        def to_s
          "\n\n#{self.class} (#{message}) #{source_location}:\n\n" +
            "#{source_listing}\n\n  #{original_exception.backtrace.join("\n  ")}\n\n"
        end
      end
    end
  end
end
