module FactoryGirl

  # Raised when calling Factory.sequence from a dynamic attribute block
  class SequenceAbuseError < StandardError; end

  # Sequences are defined using sequence within a FactoryGirl.define block.
  # Sequence values are generated using next.
  class Sequence
    attr_reader :name

    def initialize(name, value = 1, &proc) #:nodoc:
      @name = name
      @proc  = proc
      @value = value || 1
    end

    def next
      @proc ? @proc.call(@value) : @value
    ensure
      @value = @value.next
    end

    def default_strategy
      :create
    end

    def names
      [@name]
    end
  end
end
