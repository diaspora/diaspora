#encoding: utf-8
require 'spec_helper'

module Gherkin
  module Lexer
    shared_examples_for "parsing windows files" do
      describe "with BOM" do
        it "should work just fine" do
          scan_file("with_bom.feature")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "there is a step", 3],
            [:eof]
          ]
        end
      end
    end
  end
end
