#
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

require 'logger'
require 'time'

module Mixlib
  module Log
    class Formatter < Logger::Formatter
      @@show_time = true
      
      def self.show_time=(show=false)
        @@show_time = show
      end
      
      # Prints a log message as '[time] severity: message' if Chef::Log::Formatter.show_time == true.
      # Otherwise, doesn't print the time.
      def call(severity, time, progname, msg)
        if @@show_time
          sprintf("[%s] %s: %s\n", time.rfc2822(), severity, msg2str(msg))
        else
          sprintf("%s: %s\n", severity, msg2str(msg))
        end
      end
      
      # Converts some argument to a Logger.severity() call to a string.  Regular strings pass through like
      # normal, Exceptions get formatted as "message (class)\nbacktrace", and other random stuff gets 
      # put through "object.inspect"
      def msg2str(msg)
        case msg
        when ::String
          msg
        when ::Exception
          "#{ msg.message } (#{ msg.class })\n" <<
            (msg.backtrace || []).join("\n")
        else
          msg.inspect
        end
      end
    end
  end
end