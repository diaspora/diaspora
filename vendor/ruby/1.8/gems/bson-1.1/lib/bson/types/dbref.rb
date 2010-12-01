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

  # A reference to another object in a MongoDB database.
  class DBRef

    attr_reader :namespace, :object_id

    # Create a DBRef. Use this class in conjunction with DB#dereference.
    #
    # @param [String] a collection name
    # @param [ObjectID] an object id
    #
    # @core dbrefs constructor_details
    def initialize(namespace, object_id)
      @namespace = namespace
      @object_id = object_id
    end

    def to_s
      "ns: #{namespace}, id: #{object_id}"
    end

    def to_hash
      {"$ns" => @namespace, "$id" => @object_id }
    end

  end
end
