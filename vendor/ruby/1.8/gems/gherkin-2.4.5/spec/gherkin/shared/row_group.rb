# encoding: utf-8
require 'spec_helper'

module Gherkin
  module Lexer
    shared_examples_for "a Gherkin lexer lexing rows" do
      def scan(gherkin)
        @lexer.scan(gherkin)
      end

      rows = {
        "|a|b|\n"        => %w{a b},
        "|a|b|c|\n"      => %w{a b c},
      }
    
      rows.each do |text, expected|
        it "should parse #{text}" do
          @listener.should_receive(:row).with(r(expected), 1)
          scan(text.dup)
        end
      end

      it "should parse a row with many cells" do
        @listener.should_receive(:row).with(r(%w{a b c d e f g h i j k l m n o p}), 1)
        scan("|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|\n")
      end
    
      it "should parse multicharacter cell content" do
        @listener.should_receive(:row).with(r(%w{foo bar}), 1)
        scan("| foo | bar |\n")
      end

      it "should escape backslashed pipes" do
        @listener.should_receive(:row).with(r(['|', 'the', '\a', '\\', '|\\|']), 1)
        scan('| \| | the | \a | \\ |   \|\\\|    |' + "\n")
      end

      it "should parse cells with newlines" do
        @listener.should_receive(:row).with(r(["\n"]), 1)
        scan("|\\n|" + "\n")
      end
    
      it "should parse cells with spaces within the content" do
        @listener.should_receive(:row).with(r(["Dill pickle", "Valencia orange"]), 1)
        scan("| Dill pickle | Valencia orange |\n")
      end
      
      it "should allow utf-8" do
        scan(" | ůﻚ | 2 | \n")
        @listener.to_sexp.should == [
          [:row, ["ůﻚ", "2"], 1],
          [:eof]
        ]
      end 

      it "should allow utf-8 using should_receive" do
        @listener.should_receive(:row).with(r(['繁體中文  而且','並且','繁體中文  而且','並且']), 1)
        scan("| 繁體中文  而且|並且| 繁體中文  而且|並且|\n")
      end

      it "should parse a 2x2 table" do
        @listener.should_receive(:row).with(r(%w{1 2}), 1)
        @listener.should_receive(:row).with(r(%w{3 4}), 2)
        scan("| 1 | 2 |\n| 3 | 4 |\n")
      end

      it "should parse a 2x2 table with empty cells" do
        @listener.should_receive(:row).with(r(['1', '']), 1)
        @listener.should_receive(:row).with(r(['', '4']), 2)
        scan("| 1 |  |\n|| 4 |\n")
      end

      it "should parse a row with empty cells" do
        @listener.should_receive(:row).with(r(['1', '']), 1).twice
        scan("| 1 |  |\n")
        scan("|1||\n")
      end
    
      it "should parse a 1x2 table that does not end in a newline" do
        @listener.should_receive(:row).with(r(%w{1 2}), 1)
        scan("| 1 | 2 |")
      end

      it "should parse a row without spaces and with a newline" do
        @listener.should_receive(:row).with(r(%w{1 2}), 1)
        scan("|1|2|\n")
      end
      
      it "should parse a row with whitespace after the rows" do
        @listener.should_receive(:row).with(r(%w{1 2}), 1)
        scan("| 1 | 2 | \n ")
      end
      
      it "should parse a row with lots of whitespace" do
        @listener.should_receive(:row).with(r(["abc", "123"]), 1)
        scan("  \t| \t   abc\t| \t123\t \t\t| \t\t   \t \t\n  ")
      end

      it "should parse a table with a commented-out row" do
        @listener.should_receive(:row).with(r(["abc"]), 1)
        @listener.should_receive(:comment).with("#|123|", 2)
        @listener.should_receive(:row).with(r(["def"]), 3)
        scan("|abc|\n#|123|\n|def|\n") 
      end
      
      it "should raise LexingError for rows that aren't closed" do
        lambda { 
          scan("|| oh hello \n") 
        }.should raise_error(/Lexing error on line 1: '\|\| oh hello/)
      end

      it "should raise LexingError for rows that are followed by a comment" do
        lambda { 
          scan("|hi| # oh hello \n") 
        }.should raise_error(/Lexing error on line 1: '\|hi\| # oh hello/)
      end

      it "should raise LexingError for rows that aren't closed" do
        lambda { 
          scan("|| oh hello \n  |Shoudn't Get|Here|") 
        }.should raise_error(/Lexing error on line 1: '\|\| oh hello/)
      end
    end
  end
end
