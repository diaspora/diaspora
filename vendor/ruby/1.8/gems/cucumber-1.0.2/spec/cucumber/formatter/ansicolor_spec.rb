require 'spec_helper'
require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    describe ANSIColor do
      include ANSIColor
      
      it "should wrap passed_param with bold green and reset to green" do
        passed_param("foo").should == "\e[32m\e[1mfoo\e[0m\e[0m\e[32m"
      end

      it "should wrap passed in green" do
        passed("foo").should == "\e[32mfoo\e[0m"
      end

      it "should not reset passed if there are no arguments" do
        passed.should == "\e[32m"
      end

      it "should wrap comments in grey" do
        comment("foo").should == "\e[90mfoo\e[0m"
      end
      
      it "should not generate ansi codes when colors are disabled" do
        ::Term::ANSIColor.coloring = false
        passed("foo").should == "foo"
      end
    end
  end
end
