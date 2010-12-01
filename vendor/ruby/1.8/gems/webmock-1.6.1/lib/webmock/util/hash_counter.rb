module WebMock
  module Util
    class Util::HashCounter
      attr_accessor :hash
      def initialize
        self.hash = {}
        @order = {}
        @max = 0
      end
      def put key, num=1
        hash[key] = (hash[key] || 0) + num
        @order[key] = @max = @max + 1
      end
      def get key
        hash[key] || 0
      end

      def each(&block)
        @order.to_a.sort {|a, b| a[1] <=> b[1]}.each do |a|
          block.call(a[0], hash[a[0]])
        end
      end
    end
  end
end
