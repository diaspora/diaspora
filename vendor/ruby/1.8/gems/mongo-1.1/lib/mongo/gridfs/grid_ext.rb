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

module Mongo
  module GridExt
    module InstanceMethods

      # Check the existence of a file matching the given query selector.
      #
      # Note that this method can be used with both the Grid and GridFileSystem classes. Also
      # keep in mind that if you're going to be performing lots of existence checks, you should
      # keep an instance of Grid or GridFileSystem handy rather than instantiating for each existence
      # check. Alternatively, simply keep a reference to the proper files collection and query that
      # as needed. That's exactly how this methods works.
      #
      # @param [Hash] selector a query selector.
      #
      # @example
      #
      #   # Check for the existence of a given filename
      #   @grid = GridFileSystem.new(@db)
      #   @grid.exist?(:filename => 'foo.txt')
      #
      #   # Check for existence filename and content type
      #   @grid = GridFileSystem.new(@db)
      #   @grid.exist?(:filename => 'foo.txt', :content_type => 'image/jpg')
      #
      #   # Check for existence by _id
      #   @grid = Grid.new(@db)
      #   @grid.exist?(:_id => BSON::ObjectId.from_string('4bddcd24beffd95a7db9b8c8'))
      #
      #   # Check for existence by an arbitrary attribute.
      #   @grid = Grid.new(@db)
      #   @grid.exist?(:tags => {'$in' => ['nature', 'zen', 'photography']})
      #
      # @return [nil, Hash] either nil for the file's metadata as a hash.
      def exist?(selector)
        @files.find_one(selector)
      end
    end
  end
end
