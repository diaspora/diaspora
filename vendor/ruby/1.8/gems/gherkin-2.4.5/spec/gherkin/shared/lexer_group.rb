#encoding: utf-8
require 'spec_helper'

module Gherkin
  module Lexer
    shared_examples_for "a Gherkin lexer" do
      def scan(gherkin)
        @lexer.scan(gherkin)
      end

      describe "Comments" do
        it "should parse a one line comment" do
          scan("# My comment\n")
          @listener.to_sexp.should == [
            [:comment, "# My comment", 1],
            [:eof]
          ]
        end

        it "should parse a multiline comment" do
          scan("# Hello\n\n# World\n")
          @listener.to_sexp.should == [
            [:comment, "# Hello", 1],
            [:comment, "# World", 3],
            [:eof]
          ]
        end

        it "should not consume comments as part of a multiline name" do
          scan("Scenario: test\n#hello\n Scenario: another")
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "test", "", 1],
            [:comment, "#hello", 2],
            [:scenario, "Scenario", "another", "", 3],
            [:eof]
          ]
        end

        it "should not consume comments as part of a multiline example name" do
          scan("Examples: thing\n# ho hum\n| 1 | 2 |\n| 3 | 4 |\n")
          @listener.to_sexp.should == [
            [:examples, "Examples", "thing", "", 1],
            [:comment,  "# ho hum", 2],
            [:row, ["1","2"], 3],
            [:row, ["3","4"], 4],
            [:eof]
          ]
        end

        it "should allow empty comment lines" do 
          scan("#\n   # A comment\n   #\n")
          @listener.to_sexp.should == [
            [:comment, "#", 1],
            [:comment, "# A comment", 2],
            [:comment, "#", 3],
            [:eof]
          ]
        end
        
        it "should not allow comments within the Feature description" do
          lambda { 
            scan("Feature: something\nAs a something\n# Comment\nI want something") 
            }.should raise_error(/Lexing error on line 4/)
        end
      end

      describe "Tags" do
        it "should not take the tags as part of a multiline name feature element" do
          scan("Feature: hi\n Scenario: test\n\n@hello\n Scenario: another")
          @listener.to_sexp.should == [
            [:feature, "Feature", "hi", "", 1],
            [:scenario, "Scenario", "test", "", 2],
            [:tag, "@hello", 4],
            [:scenario, "Scenario", "another", "", 5],
            [:eof]
          ]
        end  
      end

      describe "Background" do
        it "should allow an empty background name and description" do
          scan("Background:\nGiven I am a step\n")
          @listener.to_sexp.should == [
            [:background, "Background", "", "", 1],
            [:step, "Given ", "I am a step", 2],
            [:eof]
          ]
        end

        it "should allow an empty background description" do
          scan("Background: Yeah\nGiven I am a step\n")
          @listener.to_sexp.should == [
            [:background, "Background", "Yeah", "", 1],
            [:step, "Given ", "I am a step", 2],
            [:eof]
          ]
        end
        
        it "should allow multiline descriptions ending at eof" do
          scan("Background: I have several\n   Lines to look at\n   None starting with Given")
          @listener.to_sexp.should == [
            [:background, "Background", "I have several", " Lines to look at\n None starting with Given", 1],
            [:eof]
          ]
        end
         
        it "should allow multiline descriptions, including whitespace" do
          scan(%{Feature: Hi
Background: It is my ambition to say 
  in ten sentences
    what others say 
  in a whole book.
Given I am a step})
          @listener.to_sexp.should == [
            [:feature, "Feature", "Hi", "", 1],
            [:background, "Background", "It is my ambition to say", "in ten sentences\n  what others say \nin a whole book.",2],
            [:step, "Given ", "I am a step", 6],
            [:eof]
          ]
        end
      end

      describe "Scenarios" do
        it "should be parsed" do
          scan("Scenario: Hello\n")
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "Hello", "", 1],
            [:eof]
          ]
        end
 
        it "should allow whitespace lines after the Scenario line" do
          scan(%{Scenario: bar

                          Given baz
                          })
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "bar", "", 1],
            [:step, "Given ", "baz", 3],
            [:eof]
          ]
        end
        
        it "should allow multiline descriptions, including whitespace" do
          scan(%{Scenario: It is my ambition to say
  in ten sentences
  what others say 
      in a whole book.
  Given I am a step
})
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "It is my ambition to say", "in ten sentences\nwhat others say \n    in a whole book.", 1],
            [:step, "Given ", "I am a step", 5],
            [:eof]
          ]
        end

        it "should allow multiline names ending at eof" do
          scan("Scenario: I have several\nLines to look at\n None starting with Given")
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "I have several", "Lines to look at\nNone starting with Given", 1],
            [:eof]
          ]
        end
  
        it "should ignore gherkin keywords embedded in other words" do
          scan(%{Scenario: I have a Button
Buttons are great
Given I have some
But I might not because I am a Charles Dickens character
})
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "I have a Button", "Buttons are great", 1],
            [:step, "Given ", "I have some", 3],
            [:step, "But ", "I might not because I am a Charles Dickens character", 4],
            [:eof]
          ]
        end
        
        it "should allow step keywords in Scenario names" do
          scan(%{Scenario: When I have when in scenario
I should be fine
Given I am a step
})
          @listener.to_sexp.should == [
            [:scenario, "Scenario", "When I have when in scenario", "I should be fine", 1],
            [:step, "Given ", "I am a step", 3],
            [:eof]
          ]
        end
      end

      describe "Scenario Outlines" do
        it "should be parsed" do
          scan(<<-HERE)
Scenario Outline: Hello
  With a description
  Given a <what> cucumber
  Examples: With a name
    and a description
    |what|
    |green|
HERE
          @listener.to_sexp.should == [
            [:scenario_outline, "Scenario Outline", "Hello", "With a description", 1],
            [:step, "Given ", "a <what> cucumber", 3],
            [:examples, "Examples", "With a name", "and a description", 4],
            [:row, ["what"], 6],
            [:row, ["green"], 7],
            [:eof]
          ]
        end


        it "should parse with no steps or examples" do
          scan(%{Scenario Outline: Hello

                          Scenario: My Scenario
                          })
          @listener.to_sexp.should == [
            [:scenario_outline, "Scenario Outline", "Hello", "", 1],
            [:scenario, "Scenario", "My Scenario", "", 3],
            [:eof]
          ]
        end

        it "should allow multiline description" do
          scan(<<-HERE)
Scenario Outline: It is my ambition to say 
  in ten sentences
    what others say 
  in a whole book.
  Given I am a step
HERE
          @listener.to_sexp.should == [
            [:scenario_outline, "Scenario Outline", "It is my ambition to say", "in ten sentences\n  what others say \nin a whole book.", 1],
            [:step, "Given ", "I am a step", 5],
            [:eof]
          ]
        end        
      end

      describe "Examples" do
        it "should be parsed" do
          scan(%{Examples:
                          |x|y|
                          |5|6|
                          })
          @listener.to_sexp.should == [
            [:examples, "Examples", "", "", 1],
            [:row, ["x","y"], 2],
            [:row, ["5","6"], 3],
            [:eof]
          ]
        end
        
        it "should parse multiline example names" do
          scan(%{Examples: I'm a multiline name
and I'm ok
f'real
|x|
|5|
})
          @listener.to_sexp.should == [
            [:examples, "Examples", "I'm a multiline name", "and I'm ok\nf'real", 1],
            [:row, ["x"], 4],
            [:row, ["5"], 5],
            [:eof]
          ]
        end
      end
      
      describe "Steps" do
        it "should parse steps with inline table" do
          scan(%{Given I have a table 
                          |a|b|
                          })
          @listener.to_sexp.should == [
            [:step, "Given ", "I have a table", 1],
            [:row, ['a','b'], 2],
            [:eof]
          ]
        end
        
        it "should parse steps with inline doc_string" do
          scan("Given I have a string\n\"\"\"\nhello\nworld\n\"\"\"")
          @listener.to_sexp.should == [
            [:step, "Given ", "I have a string", 1],
            [:doc_string, "hello\nworld", 2],
            [:eof]
          ]
        end
      end
            
      describe "A single feature, single scenario, single step" do
        it "should find the feature, scenario, and step" do
          scan("Feature: Feature Text\n  Scenario: Reading a Scenario\n    Given there is a step\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "there is a step", 3],
            [:eof]
          ]
        end
      end

      describe "A feature ending in whitespace" do
        it "should not raise an error when whitespace follows the Feature, Scenario, and Steps" do
          scan("Feature: Feature Text\n Scenario: Reading a Scenario\n    Given there is a step\n    ")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "there is a step", 3],
            [:eof]
          ]
        end
      end

      describe "A single feature, single scenario, three steps" do
        
        it "should find the feature, scenario, and three steps" do
          scan("Feature: Feature Text\n  Scenario: Reading a Scenario\n    Given there is a step\n    And another step\n   And a third step\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "there is a step", 3],
            [:step, "And ", "another step", 4],
            [:step, "And ", "a third step", 5],
            [:eof]
          ]
        end
      end

      describe "A single feature with no scenario" do
        it "should find the feature" do
          scan("Feature: Feature Text\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:eof]
          ]
        end

        it "should parse a one line feature with no newline" do
          scan("Feature: hi")
          @listener.to_sexp.should == [
            [:feature, "Feature", "hi", "", 1],
            [:eof]
          ]
        end
      end
      
      describe "A multi-line feature with no scenario" do
        it "should find the feature" do
          scan("Feature: Feature Text\n  And some more text")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "And some more text", 1],
            [:eof]
          ]
        end
      end

      describe "A feature with a scenario but no steps" do
        it "should find the feature and scenario" do
          scan("Feature: Feature Text\nScenario: Reading a Scenario\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:eof]
          ]
        end
      end

      describe "A feature with two scenarios" do
        it "should find the feature and two scenarios" do
          scan("Feature: Feature Text\nScenario: Reading a Scenario\n  Given a step\n\nScenario: A second scenario\n Given another step\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "a step", 3],
            [:scenario, "Scenario", "A second scenario", "", 5],
            [:step, "Given ", "another step", 6],
            [:eof]
          ]
        end
        
        it "should find the feature and two scenarios without indentation" do
          scan("Feature: Feature Text\nScenario: Reading a Scenario\nGiven a step\nScenario: A second scenario\nGiven another step\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Feature Text", "", 1],
            [:scenario, "Scenario", "Reading a Scenario", "", 2],
            [:step, "Given ", "a step", 3],
            [:scenario, "Scenario", "A second scenario", "", 4],
            [:step, "Given ", "another step", 5],
            [:eof]
          ]
        end
      end

      describe "A simple feature with comments" do
        it "should find the feature, scenarios, steps, and comments in the proper order" do
          scan_file("simple_with_comments.feature")
          @listener.to_sexp.should == [
            [:comment, "# Here is a comment", 1],
            [:feature, "Feature", "Feature Text", "", 2],
            [:comment, "# Here is another # comment", 3],
            [:scenario, "Scenario", "Reading a Scenario", "", 4],
            [:comment, "# Here is a third comment", 5],
            [:step, "Given ", "there is a step", 6],
            [:comment, "# Here is a fourth comment", 7],
            [:eof]
          ]
        end

        it "should support comments in tables" do
          scan_file("comments_in_table.feature")
          @listener.to_sexp.should == [
            [:feature, "Feature", "x", "", 1], 
            [:scenario_outline, "Scenario Outline", "x", "", 3], 
            [:step, "Then ", "x is <state>", 4], 
            [:examples, "Examples", "", "", 6], 
            [:row, ["state"], 7], 
            [:comment, "# comment", 8], 
            [:row, ["1"], 9],
            [:eof]
          ]
        end
      end
      
      describe "A feature with tags everywhere" do
        it "should find the feature, scenario, step, and tags in the proper order" do
          scan_file("simple_with_tags.feature")
          @listener.to_sexp.should == [
            [:comment, "# FC", 1],
            [:tag, "@ft",2],
            [:feature, "Feature", "hi", "", 3],
            [:tag, "@st1", 5],
            [:tag, "@st2", 5],
            [:scenario, "Scenario", "First", "", 6],
            [:step, "Given ", "Pepper", 7],
            [:tag, "@st3", 9],
            [:tag, "@st4", 10],
            [:tag, "@ST5", 10],
            [:tag, "@#^%&ST6**!", 10],
            [:scenario, "Scenario", "Second", "", 11],
            [:eof]
          ]
        end        
      end

      describe "Comment or tag between Feature elements where previous narrative starts with same letter as a keyword" do
        it "should lex this feature properly" do
          scan_file("1.feature")
          @listener.to_sexp.should == [
            [:feature, "Feature", "Logging in", "So that I can be myself", 1],
            [:comment, "# Comment", 3],
            [:scenario, "Scenario", "Anonymous user can get a login form.", "Scenery here", 4],
            [:tag, "@tag", 7],
            [:scenario, "Scenario", "Another one", "", 8],
            [:eof]
          ]
        end
      end   

      describe "A complex feature with tags, comments, multiple scenarios, and multiple steps and tables" do
        it "should find things in the right order" do
          scan_file("complex.feature")
          @listener.to_sexp.should == [
            [:comment, "#Comment on line 1", 1],
            [:comment, "#Comment on line 2", 2],
            [:tag, "@tag1", 3],
            [:tag, "@tag2", 3],
            [:feature, "Feature", "Feature Text", "In order to test multiline forms\nAs a ragel writer\nI need to check for complex combinations", 4],
            [:comment, "#Comment on line 9", 9],
            [:comment, "#Comment on line 11", 11],
            [:background, "Background", "", "", 13],
            [:step, "Given ", "this is a background step", 14],
            [:step, "And ", "this is another one", 15],
            [:tag, "@tag3", 17],
            [:tag, "@tag4", 17],
            [:scenario, "Scenario", "Reading a Scenario", "", 18],
            [:step, "Given ", "there is a step", 19],
            [:step, "But ", "not another step", 20],
            [:tag, "@tag3", 22],
            [:scenario, "Scenario", "Reading a second scenario", "With two lines of text", 23],
            [:comment, "#Comment on line 24", 25],
            [:step, "Given ", "a third step with a table", 26],
            [:row, %w{a b}, 27],
            [:row, %w{c d}, 28],
            [:row, %w{e f}, 29],
            [:step, "And ", "I am still testing things", 30],
            [:row, %w{g h}, 31],
            [:row, %w{e r}, 32],
            [:row, %w{k i}, 33],
            [:row, ['n', ''], 34], 
            [:step, "And ", "I am done testing these tables", 35],
            [:comment, "#Comment on line 29", 36],
            [:step, "Then ", "I am happy", 37],
            [:scenario, "Scenario", "Hammerzeit", "", 39],
            [:step, "Given ", "All work and no play", 40],
            [:doc_string, "Makes Homer something something\nAnd something else", 41 ],
            [:step, "Then ", "crazy", 45],
            [:eof]
          ]
        end        
      end
      
      describe "Windows stuff" do
        it "should find things in the right order for CRLF features" do
          scan_file("dos_line_endings.feature")
          @listener.to_sexp.should == [
            [:comment, "#Comment on line 1", 1],
            [:comment, "#Comment on line 2", 2],
            [:tag, "@tag1", 3],
            [:tag, "@tag2", 3],
            [:feature, "Feature", "Feature Text", "In order to test multiline forms\r\nAs a ragel writer\r\nI need to check for complex combinations", 4],
            [:comment, "#Comment on line 9", 9],
            [:comment, "#Comment on line 11", 11],
            [:background, "Background", "", "", 13],
            [:step, "Given ", "this is a background step", 14],
            [:step, "And ", "this is another one", 15],
            [:tag, "@tag3", 17],
            [:tag, "@tag4", 17],
            [:scenario, "Scenario", "Reading a Scenario", "", 18],
            [:step, "Given ", "there is a step", 19],
            [:step, "But ", "not another step", 20],
            [:tag, "@tag3", 22],
            [:scenario, "Scenario", "Reading a second scenario", "With two lines of text", 23],
            [:comment, "#Comment on line 24", 25],
            [:step, "Given ", "a third step with a table", 26],
            [:row, %w{a b}, 27],
            [:row, %w{c d}, 28],
            [:row, %w{e f}, 29],
            [:step, "And ", "I am still testing things", 30],
            [:row, %w{g h}, 31],
            [:row, %w{e r}, 32],
            [:row, %w{k i}, 33],
            [:row, ['n', ''], 34], 
            [:step, "And ", "I am done testing these tables", 35],
            [:comment, "#Comment on line 29", 36],
            [:step, "Then ", "I am happy", 37],
            [:scenario, "Scenario", "Hammerzeit", "", 39],
            [:step, "Given ", "All work and no play", 40],
            [:doc_string, "Makes Homer something something\r\nAnd something else", 41],
            [:step, "Then ", "crazy", 45],
            [:eof]
          ]
        end
      end

      describe "errors" do
        it "should raise a Lexing error if an unparseable token is found" do
          ["Some text\nFeature: Hi", 
            "Feature: Hi\nBackground:\nGiven something\nScenario A scenario",
            "Scenario: My scenario\nGiven foo\nAand bar\nScenario: another one\nGiven blah"].each do |text|
              lambda { scan(text) }.should raise_error(/Lexing error on line/)
          end
        end
        
        it "should include the line number and context of the error" do
          lambda {
            scan("Feature: hello\nScenario: My scenario\nGiven foo\nAand blah\nHmmm wrong\nThen something something")
          }.should raise_error(/Lexing error on line 4/)
        end

        it "Feature keyword should terminate narratives for multiline capable tokens" do
          scan("Feature:\nBackground:\nFeature:\nScenario Outline:\nFeature:\nScenario:\nFeature:\nExamples:\nFeature:\n")
          @listener.to_sexp.should == [
            [:feature, "Feature", "", "", 1],
            [:background, "Background", "", "", 2],
            [:feature, "Feature", "", "", 3],
            [:scenario_outline, "Scenario Outline", "", "", 4],
            [:feature, "Feature", "", "", 5],
            [:scenario, "Scenario", "", "", 6],
            [:feature, "Feature", "", "", 7],
            [:examples, "Examples", "","",  8],
            [:feature, "Feature", "", "", 9],
            [:eof]
          ]
        end
      end
    end
  end
end
