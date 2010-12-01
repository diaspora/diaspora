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

# A thin wrapper for the CBson class
module BSON
  class BSON_C

    def self.serialize(obj, check_keys=false, move_id=false)
      ByteBuffer.new(CBson.serialize(obj, check_keys, move_id))
    end

    def self.deserialize(buf=nil)
      CBson.deserialize(ByteBuffer.new(buf).to_s)
    end

  end
end
