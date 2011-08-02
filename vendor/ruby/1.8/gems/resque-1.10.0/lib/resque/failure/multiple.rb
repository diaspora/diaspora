module Resque
  module Failure
    # A Failure backend that uses multiple backends
    # delegates all queries to the first backend
    class Multiple < Base

      class << self
        attr_accessor :classes
      end

      def self.configure
        yield self
        Resque::Failure.backend = self
      end

      def initialize(*args)
        super
        @backends = self.class.classes.map {|klass| klass.new(*args)}
      end

      def save
        @backends.each(&:save)
      end

      # The number of failures.
      def self.count
        classes.first.count
      end

      # Returns a paginated array of failure objects.
      def self.all(start = 0, count = 1)
        classes.first.all(start,count)
      end

      # A URL where someone can go to view failures.
      def self.url
        classes.first.url
      end

      # Clear all failure objects
      def self.clear
        classes.first.clear
      end

      def self.requeue(*args)
        classes.first.requeue(*args)
      end
    end
  end
end