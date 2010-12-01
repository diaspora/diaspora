require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/formatter/duration'

module Cucumber
  module Formatter
    describe Duration do
      include Duration
      
      it "should format ms" do
        format_duration(0.002103).should == '0m0.002s'
      end

      it "should format m" do
        format_duration(61.002503).should == '1m1.003s'
      end

      it "should format h" do
        format_duration(3661.002503).should == '61m1.003s'
      end
    end
  end
end