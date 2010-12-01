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
  # Generic Mongo Ruby Driver exception class.
  class MongoRubyError < StandardError; end

  # Raised when MongoDB itself has returned an error.
  class MongoDBError < RuntimeError; end

  # This will replace MongoDBError.
  class BSONError < MongoDBError; end

  # Raised when given a string is not valid utf-8 (Ruby 1.8 only).
  class InvalidStringEncoding < BSONError; end

  # Raised when attempting to initialize an invalid ObjectID.
  class InvalidObjectID < BSONError; end

  # Raised when attempting to initialize an invalid ObjectID.
  class InvalidObjectId < BSONError; end

  # Raised when trying to insert a document that exceeds the 4MB limit or
  # when the document contains objects that can't be serialized as BSON.
  class InvalidDocument < BSONError; end

  # Raised when an invalid name is used.
  class InvalidKeyName < BSONError; end
end
