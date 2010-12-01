class Factory

  # Raised when calling Factory.sequence from a dynamic attribute block
  class SequenceAbuseError < StandardError; end

  # Sequences are defined using Factory.sequence. Sequence values are generated
  # using next.
  class Sequence

    def initialize (&proc) #:nodoc:
      @proc  = proc
      @value = 0
    end

    # Returns the next value for this sequence
    def next
      @value += 1
      @proc.call(@value)
    end

  end

  class << self
    attr_accessor :sequences #:nodoc:
  end
  self.sequences = {}

  # Defines a new sequence that can be used to generate unique values in a specific format.
  #
  # Arguments:
  #   name: (Symbol)
  #     A unique name for this sequence. This name will be referenced when
  #     calling next to generate new values from this sequence.
  #   block: (Proc)
  #     The code to generate each value in the sequence. This block will be
  #     called with a unique number each time a value in the sequence is to be
  #     generated. The block should return the generated value for the
  #     sequence.
  #
  # Example:
  #
  #   Factory.sequence(:email) {|n| "somebody_#{n}@example.com" }
  def self.sequence (name, &block)
    self.sequences[name] = Sequence.new(&block)
  end

  # Generates and returns the next value in a sequence.
  #
  # Arguments:
  #   name: (Symbol)
  #     The name of the sequence that a value should be generated for.
  #
  # Returns:
  #   The next value in the sequence. (Object)
  def self.next (sequence)
    unless self.sequences.key?(sequence)
      raise "No such sequence: #{sequence}"
    end

    self.sequences[sequence].next
  end

end
