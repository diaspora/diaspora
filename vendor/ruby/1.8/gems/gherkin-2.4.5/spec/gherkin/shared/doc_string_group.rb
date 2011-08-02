# encoding: utf-8
require 'spec_helper'

module Gherkin
  module Lexer
    shared_examples_for "a Gherkin lexer lexing doc_strings" do
      def scan(gherkin)
        @lexer.scan(gherkin)
      end

      def ps(content)
        '"""%s"""' % ("\n" + content + "\n")
      end
      
      it "should provide the amount of indentation of the triple quotes to the listener" do
str = <<EOS
Feature: some feature
  Scenario: some scenario
    Given foo
    """
      Hello
    Goodbye
    """
    Then bar
EOS
        @listener.should_receive(:doc_string).with("  Hello\nGoodbye", 4)
        scan(str)
      end

      it "should parse a simple doc_string" do
        @listener.should_receive(:doc_string).with("I am a doc_string", 1)
        scan ps("I am a doc_string")
      end

      it "should parse an empty doc_string" do
        @listener.should_receive(:doc_string).with("", 4)
        scan("Feature: Hi\nScenario: Hi\nGiven a step\n\"\"\"\n\"\"\"")
      end

      it "should treat a string containing only newlines as only newlines" do
doc_string = <<EOS
"""



"""
EOS
        @listener.should_receive(:doc_string).with("\n\n", 1)
        scan(doc_string)
      end
      
      it "should parse content separated by two newlines" do
        scan ps("A\n\nB")
        @listener.to_sexp.should == [
          [:doc_string, "A\n\nB", 1],
          [:eof]
        ]
      end
      
      it "should parse a multiline string" do
        @listener.should_receive(:doc_string).with("A\nB\nC\nD", 1)
        scan ps("A\nB\nC\nD")
      end
            
      it "should ignore unescaped quotes inside the string delimeters" do
        @listener.should_receive(:doc_string).with("What does \"this\" mean?", 1)
        scan ps('What does "this" mean?')
      end
      
      it "should preserve whitespace within the triple quotes" do
str = <<EOS
    """
      Line one
 Line two
    """
EOS
        @listener.should_receive(:doc_string).with("  Line one\nLine two", 1)
        scan(str)
      end
            
      it "should preserve tabs within the content" do
        @listener.should_receive(:doc_string).with("I have\tsome tabs\nInside\t\tthe content", 1)
        scan ps("I have\tsome tabs\nInside\t\tthe content")
      end
  
      it "should handle complex doc_strings" do
doc_string = <<EOS
# Feature comment
@one
Feature: Sample

  @two @three
  Scenario: Missing
    Given missing

1 scenario (1 passed)
1 step (1 passed)

EOS
        
        @listener.should_receive(:doc_string).with(doc_string, 1)
        scan ps(doc_string)
      end
 
      it "should allow whitespace after the closing doc_string delimiter" do
str = <<EOS
    """
      Line one
    """           
EOS
        @listener.should_receive(:doc_string).with("  Line one", 1)
        scan(str)
      end

      it "should preserve the last newline(s) at the end of a doc_string" do
str = <<EOS
     """
     DocString text


     """
EOS
        @listener.should_receive(:doc_string).with("DocString text\n\n",1)
        scan(str)
      end        

      it "should preserve CRLFs within doc_strings" do
        @listener.should_receive(:doc_string).with("Line one\r\nLine two\r\n", 1)
        scan("\"\"\"\r\nLine one\r\nLine two\r\n\r\n\"\"\"")
      end

      it "should unescape escaped triple quotes" do
str = <<EOS
    """
    \\"\\"\\"
    """
EOS
        @listener.should_receive(:doc_string).with('"""', 1)
        scan(str)
      end

      it "should not unescape escaped single quotes" do
str = <<EOS
    """
    \\" \\"\\"
    """
EOS
        @listener.should_receive(:doc_string).with('\" \"\"', 1)
        scan(str)
      end
    end
  end
end
