# :stopdoc:
if ENV['NOKOGIRI_ID2REF'] || RUBY_PLATFORM !~ /java/
  Nokogiri::VERSION_INFO['refs'] = "id2ref"
else
  require 'weakling'
  Nokogiri::VERSION_INFO['refs'] = "weakling"
end
require 'singleton'

module Nokogiri
  class WeakBucket
    include Singleton

    if Nokogiri::VERSION_INFO['refs'] == "weakling"
      attr_accessor :bucket

      def initialize
        @bucket = Weakling::IdHash.new
      end

      def WeakBucket.get_object(cstruct)
        instance.bucket[cstruct.ruby_node_pointer]
      end

      def WeakBucket.set_object(cstruct, object)
        cstruct.ruby_node_pointer = instance.bucket.add(object)
      end
    else
      def WeakBucket.get_object(cstruct)
        ptr = cstruct.ruby_node_pointer
        ptr != 0 ? ObjectSpace._id2ref(ptr) : nil
      end

      def WeakBucket.set_object(cstruct, object)
        cstruct.ruby_node_pointer = object.object_id
      end
    end
  end
end
# :startdoc:
