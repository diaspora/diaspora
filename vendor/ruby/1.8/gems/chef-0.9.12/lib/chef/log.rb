#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: AJ Christensen (<@aj@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
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

require 'logger'
require 'mixlib/log'

class Chef
  class Log
    extend Mixlib::Log
    
    class << self
      attr_accessor :verbose
      attr_reader :verbose_logger
      protected :verbose_logger
      
      def verbose
        !(@verbose_logger.nil?)
      end

      def verbose=(value)
        if value
          @verbose_logger ||= Logger.new(STDOUT)
          @verbose_logger.level = self.logger.level
          @verbose_logger.formatter = self.logger.formatter
        else
          @verbose_logger = nil
        end
        self.verbose
      end
      
      def method_missing(method_symbol, *args)
        self.verbose_logger.send(method_symbol, *args) if self.verbose
        logger.send(method_symbol, *args)
      end
    end  

    class Formatter
      def self.show_time=(*args)
        Mixlib::Log::Formatter.show_time = *args
      end
    end
    
  end
end

