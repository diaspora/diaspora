module Kernel
  # :call-seq:
  #   should(matcher)
  #   should == expected
  #   should === expected
  #   should =~ expected
  #
  #   receiver.should(matcher)
  #     => Passes if matcher.matches?(receiver)
  #
  #   receiver.should == expected #any value
  #     => Passes if (receiver == expected)
  #
  #   receiver.should === expected #any value
  #     => Passes if (receiver === expected)
  #
  #   receiver.should =~ regexp
  #     => Passes if (receiver =~ regexp)
  #
  # See RSpec::Matchers for more information about matchers
  #
  # == Warning
  #
  # NOTE that this does NOT support receiver.should != expected.
  # Instead, use receiver.should_not == expected
  def should(matcher=nil, message=nil, &block)
    RSpec::Expectations::PositiveExpectationHandler.handle_matcher(self, matcher, message, &block)
  end
  
  # :call-seq:
  #   should_not(matcher)
  #   should_not == expected
  #   should_not === expected
  #   should_not =~ expected
  #
  #   receiver.should_not(matcher)
  #     => Passes unless matcher.matches?(receiver)
  #
  #   receiver.should_not == expected
  #     => Passes unless (receiver == expected)
  #
  #   receiver.should_not === expected
  #     => Passes unless (receiver === expected)
  #
  #   receiver.should_not =~ regexp
  #     => Passes unless (receiver =~ regexp)
  #
  # See RSpec::Matchers for more information about matchers
  def should_not(matcher=nil, message=nil, &block)
    RSpec::Expectations::NegativeExpectationHandler.handle_matcher(self, matcher, message, &block)
  end
end
