#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

class Chef
  module Mixin
    module Deprecation
      class DeprecatedObjectProxyBase
        KEEPERS = %w{__id__ __send__ instance_eval == equal? initialize object_id}
        instance_methods.each { |method_name| undef_method(method_name) unless KEEPERS.include?(method_name.to_s)}
      end

      class DeprecatedInstanceVariable < DeprecatedObjectProxyBase
        def initialize(target, ivar_name, level=nil)
          @target, @ivar_name = target, ivar_name
          @level ||= :warn
        end

        def method_missing(method_name, *args, &block)
          log_deprecation_msg(caller[0..3])
          @target.send(method_name, *args, &block)
        end

        def inspect
          @target.inspect
        end

        private

        def log_deprecation_msg(*called_from)
          called_from = called_from.flatten
          log("Accessing #{@ivar_name} by the variable @#{@ivar_name} is deprecated. Support will be removed in a future release.")
          log("Please update your cookbooks to use #{@ivar_name} in place of @#{@ivar_name}. Accessed from:")
          called_from.each {|l| log(l)}
        end

        def log(msg)
          # WTF: I don't get the log prefix (i.e., "[timestamp] LEVEL:") if I
          # send to Chef::Log. No one but me should use method_missing, ever.
          Chef::Log.logger.send(@level, msg)
        end

      end

      def deprecated_ivar(obj, name, level=nil)
        DeprecatedInstanceVariable.new(obj, name, level)
      end

    end
  end
end
