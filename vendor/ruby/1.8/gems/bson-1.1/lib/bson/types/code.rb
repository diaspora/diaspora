# encoding: UTF-8

# --
# Copyright (C) 2008-2010 10gen Inc.
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
# ++

module BSON

  # JavaScript code to be evaluated by MongoDB.
  class Code

    # Hash mapping identifiers to their values
    attr_accessor :scope, :code

    # Wrap code to be evaluated by MongoDB.
    #
    # @param [String] code the JavaScript code.
    # @param [Hash] a document mapping identifiers to values, which
    #   represent the scope in which the code is to be executed.
    def initialize(code, scope={})
      @code  = code
      @scope = scope
    end

    def length
      @code.length
    end

    def ==(other)
      self.class == other.class &&
        @code == other.code && @scope == other.scope
    end

    def inspect
      "<BSON::Code:#{object_id} @data=\"#{@code}\" @scope=\"#{@scope.inspect}\">"
    end

  end
end
