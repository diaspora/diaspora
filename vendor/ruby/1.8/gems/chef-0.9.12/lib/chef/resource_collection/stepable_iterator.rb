# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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
  class ResourceCollection
    class StepableIterator
      
      def self.for_collection(new_collection)
        instance = new(new_collection)
        instance
      end
      
      attr_accessor :collection
      attr_reader :position
      
      def initialize(collection=[])
        @position = 0
        @paused = false
        @collection = collection
      end
      
      def size
        collection.size
      end
      
      def each(&block)
        reset_iteration(block)
        @iterator_type = :element
        iterate
      end
      
      def each_index(&block)
        reset_iteration(block)
        @iterator_type = :index
        iterate
      end
      
      def each_with_index(&block)
        reset_iteration(block)
        @iterator_type = :element_with_index
        iterate
      end
      
      def paused?
        @paused
      end
      
      def pause
        @paused = true
      end
      
      def resume
        @paused = false
        iterate
      end
      
      def rewind
        @position = 0
      end
      
      def skip_back(skips=1)
        @position -= skips
      end
      
      def skip_forward(skips=1)
        @position += skips
      end
      
      def step
        return nil if @position == size
        call_iterator_block
        @position += 1
      end
      
      def iterate_on(iteration_type, &block)
        @iterator_type = iteration_type
        @iterator_block = block
      end
      
      private
      
      def reset_iteration(iterator_block)
        @iterator_block = iterator_block
        @position = 0
        @paused = false
      end
      
      def iterate
        while @position < size && !paused?
          step
        end
        collection
      end
      
      def call_iterator_block
        case @iterator_type
        when :element
          @iterator_block.call(collection[@position])
        when :index
          @iterator_block.call(@position)
        when :element_with_index
          @iterator_block.call(collection[@position], @position)
        else
          raise "42error: someone forgot to set @iterator_type, wtf?"
        end
      end
      
    end
  end
end