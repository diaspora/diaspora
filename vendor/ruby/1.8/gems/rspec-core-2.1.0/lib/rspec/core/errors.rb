module RSpec
  module Core
    # If Test::Unit is loaed, we'll use its error as baseclass, so that Test::Unit
    # will report unmet RSpec expectations as failures rather than errors.
    superclass = ['Test::Unit::AssertionFailedError', '::StandardError'].map do |c|
      eval(c) rescue nil
    end.compact.first

    class PendingExampleFixedError < superclass
    end
  end
end


