#!/usr/local/bin/ruby -w

# tc_highline.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test/unit"

require "highline"
require "stringio"

if HighLine::CHARACTER_MODE == "Win32API"
  class HighLine
    # Override Windows' character reading so it's not tied to STDIN.
    def get_character( input = STDIN )
      input.getc
    end
  end
end

class TestHighLine < Test::Unit::TestCase
  def setup
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)  
  end
  
  def test_agree
    @input << "y\nyes\nYES\nHell no!\nNo\n"
    @input.rewind

    assert_equal(true, @terminal.agree("Yes or no?  "))
    assert_equal(true, @terminal.agree("Yes or no?  "))
    assert_equal(true, @terminal.agree("Yes or no?  "))
    assert_equal(false, @terminal.agree("Yes or no?  "))
    
    @input.truncate(@input.rewind)
    @input << "yellow"
    @input.rewind

    assert_equal(true, @terminal.agree("Yes or no?  ", :getc))
  end
  
  def test_agree_with_block
    @input << "\n\n"
    @input.rewind

    assert_equal(true, @terminal.agree("Yes or no?  ") { |q| q.default = "y" })
    assert_equal(false, @terminal.agree("Yes or no?  ") { |q| q.default = "n" })
  end
  
  def test_ask
    name = "James Edward Gray II"
    @input << name << "\n"
    @input.rewind

    assert_equal(name, @terminal.ask("What is your name?  "))
    
    assert_raise(EOFError) { @terminal.ask("Any input left?  ") }
  end
  
  def test_bug_fixes
    # auto-complete bug
    @input << "ruby\nRuby\n"
    @input.rewind

    languages = [:Perl, :Python, :Ruby]
    answer = @terminal.ask( "What is your favorite programming language?  ",
                            languages )
    assert_equal(languages.last, answer)

    @input.truncate(@input.rewind)
    @input << "ruby\n"
    @input.rewind

    answer = @terminal.ask( "What is your favorite programming language?  ",
                            languages ) do |q|
      q.case = :capitalize
    end
    assert_equal(languages.last, answer)
    
    # poor auto-complete error message
    @input.truncate(@input.rewind)
    @input << "lisp\nruby\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask( "What is your favorite programming language?  ",
                            languages ) do |q|
      q.case = :capitalize
    end
    assert_equal(languages.last, answer)
    assert_equal( "What is your favorite programming language?  " +
                  "You must choose one of [:Perl, :Python, :Ruby].\n" +
                  "?  ", @output.string )
  end
  
  def test_case_changes
    @input << "jeg2\n"
    @input.rewind

    answer = @terminal.ask("Enter your initials  ") do |q|
      q.case = :up
    end
    assert_equal("JEG2", answer)

    @input.truncate(@input.rewind)
    @input << "cRaZY\n"
    @input.rewind

    answer = @terminal.ask("Enter a search string:  ") do |q|
      q.case = :down
    end
    assert_equal("crazy", answer)
  end

  def test_character_echo
    @input << "password\r"
    @input.rewind

    answer = @terminal.ask("Please enter your password:  ") do |q|
      q.echo = "*"
    end
    assert_equal("password", answer)
    assert_equal("Please enter your password:  ********\n", @output.string)

    @input.truncate(@input.rewind)
    @input << "2"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask( "Select an option (1, 2 or 3):  ",
                            Integer ) do |q|
      q.echo      = "*"
      q.character = true
    end
    assert_equal(2, answer)
    assert_equal("Select an option (1, 2 or 3):  *\n", @output.string)
  end

  def test_backspace_does_not_enter_prompt
      @input << "\b\b"
      @input.rewind
      answer = @terminal.ask("Please enter your password: ") do |q| 
          q.echo = "*" 
      end
      assert_equal("", answer)
      assert_equal("Please enter your password: \n",@output.string)
  end
  
  def test_readline_on_non_echo_question_has_prompt
    @input << "you can't see me"
    @input.rewind
    answer = @terminal.ask("Please enter some hidden text: ") do |q|
      q.readline = true
      q.echo = "*"
    end
    assert_equal("you can't see me", answer)
    assert_equal("Please enter some hidden text: ****************\n",@output.string)
  end
  
  def test_character_reading
    # WARNING:  This method does NOT cover Unix and Windows savvy testing!
    @input << "12345"
    @input.rewind

    answer = @terminal.ask("Enter a single digit:  ", Integer) do |q|
      q.character = :getc
    end
    assert_equal(1, answer)
  end

  def test_color
    @terminal.say("This should be <%= BLUE %>blue<%= CLEAR %>!")
    assert_equal("This should be \e[34mblue\e[0m!\n", @output.string)

    @output.truncate(@output.rewind)

    @terminal.say( "This should be " +
                   "<%= BOLD + ON_WHITE %>bold on white<%= CLEAR %>!" )
    assert_equal( "This should be \e[1m\e[47mbold on white\e[0m!\n",
                  @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("This should be <%= color('cyan', CYAN) %>!")
    assert_equal("This should be \e[36mcyan\e[0m!\n", @output.string)

    @output.truncate(@output.rewind)

    @terminal.say( "This should be " +
                   "<%= color('blinking on red', :blink, :on_red) %>!" )
    assert_equal( "This should be \e[5m\e[41mblinking on red\e[0m!\n",
                  @output.string )

    @output.truncate(@output.rewind)

    # turn off color
    old_setting = HighLine.use_color?
    assert_nothing_raised(Exception) { HighLine.use_color = false }
    @terminal.say("This should be <%= color('cyan', CYAN) %>!")
    assert_equal("This should be cyan!\n", @output.string)
    HighLine.use_color = old_setting
  end
                                  
  def test_confirm
    @input << "junk.txt\nno\nsave.txt\ny\n"
    @input.rewind

    answer = @terminal.ask("Enter a filename:  ") do |q|
      q.confirm = "Are you sure you want to overwrite <%= @answer %>?  "
      q.responses[:ask_on_error] = :question
    end
    assert_equal("save.txt", answer)
    assert_equal( "Enter a filename:  " +
                  "Are you sure you want to overwrite junk.txt?  " +
                  "Enter a filename:  " +
                  "Are you sure you want to overwrite save.txt?  ",
                  @output.string )

    @input.truncate(@input.rewind)
    @input << "junk.txt\nyes\nsave.txt\nn\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Enter a filename:  ") do |q|
      q.confirm = "Are you sure you want to overwrite <%= @answer %>?  "
    end
    assert_equal("junk.txt", answer)
    assert_equal( "Enter a filename:  " +
                  "Are you sure you want to overwrite junk.txt?  ",
                  @output.string )
  end
  
  def test_defaults
    @input << "\nNo Comment\n"
    @input.rewind

    answer = @terminal.ask("Are you sexually active?  ") do |q|
      q.validate = /\Ay(?:es)?|no?|no comment\Z/i
    end
    assert_equal("No Comment", answer)

    @input.truncate(@input.rewind)
    @input << "\nYes\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Are you sexually active?  ") do |q|
      q.default  = "No Comment"
      q.validate = /\Ay(?:es)?|no?|no comment\Z/i
    end
    assert_equal("No Comment", answer)
    assert_equal( "Are you sexually active?  |No Comment|  ",
                  @output.string )
  end
  
  def test_empty
    @input << "\n"
    @input.rewind

    answer = @terminal.ask("") do |q|
      q.default  = "yes"
      q.validate = /\Ay(?:es)?|no?\Z/i
    end
    assert_equal("yes", answer)
  end
  
  def test_erb
    @terminal.say( "The integers from 1 to 10 are:\n" +
                   "% (1...10).each do |n|\n" +
                   "\t<%= n %>,\n" +
                   "% end\n" +
                   "\tand 10" )
    assert_equal( "The integers from 1 to 10 are:\n" +
                  "\t1,\n\t2,\n\t3,\n\t4,\n\t5,\n" +
                  "\t6,\n\t7,\n\t8,\n\t9,\n\tand 10\n",
                  @output.string )
  end
  
  def test_files
    @input << "#{File.basename(__FILE__)[0, 5]}\n"
    @input.rewind

    file = @terminal.ask("Select a file:  ", File) do |q|
      q.directory = File.expand_path(File.dirname(__FILE__))
      q.glob      = "*.rb"
    end
    assert_instance_of(File, file)
    assert_equal("#!/usr/local/bin/ruby -w\n", file.gets)
    assert_equal("\n", file.gets)
    assert_equal("# tc_highline.rb\n", file.gets)
    file.close

    @input.rewind

    pathname = @terminal.ask("Select a file:  ", Pathname) do |q|
      q.directory = File.expand_path(File.dirname(__FILE__))
      q.glob      = "*.rb"
    end
    assert_instance_of(Pathname, pathname)
    assert_equal(File.size(__FILE__), pathname.size)
  end
  
  def test_gather
    @input << "James\nDana\nStorm\nGypsy\n\n"
    @input.rewind

    answers = @terminal.ask("Enter four names:") do |q|
      q.gather = 4
    end
    assert_equal(%w{James Dana Storm Gypsy}, answers)
    assert_equal("\n", @input.gets)
    assert_equal("Enter four names:\n", @output.string)

    @input.rewind

    answers = @terminal.ask("Enter four names:") do |q|
      q.gather = ""
    end
    assert_equal(%w{James Dana Storm Gypsy}, answers)

    @input.rewind

    answers = @terminal.ask("Enter four names:") do |q|
      q.gather = /^\s*$/
    end
    assert_equal(%w{James Dana Storm Gypsy}, answers)

    @input.truncate(@input.rewind)
    @input << "29\n49\n30\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answers = @terminal.ask("<%= @key %>:  ", Integer) do |q|
      q.gather = { "Age" => 0, "Wife's Age" => 0, "Father's Age" => 0}
    end
    assert_equal( { "Age" => 29, "Wife's Age" => 30, "Father's Age" => 49},
                  answers )
    assert_equal("Age:  Father's Age:  Wife's Age:  ", @output.string)
  end
  
  def test_lists
    digits     = %w{Zero One Two Three Four Five Six Seven Eight Nine}
    erb_digits = digits.dup
    erb_digits[erb_digits.index("Five")] = "<%= color('Five', :blue) %%>"
    
    @terminal.say("<%= list(#{digits.inspect}) %>")
    assert_equal(digits.map { |d| "#{d}\n" }.join, @output.string)
    
    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{digits.inspect}, :inline) %>")
    assert_equal( digits[0..-2].join(", ") + " or #{digits.last}\n",
                  @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{digits.inspect}, :inline, ' and ') %>")
    assert_equal( digits[0..-2].join(", ") + " and #{digits.last}\n",
                  @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{digits.inspect}, :columns_down, 3) %>")
    assert_equal( "Zero   Four   Eight\n" +
                  "One    Five   Nine \n" +
                  "Two    Six  \n" +
                  "Three  Seven\n",
                  @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{erb_digits.inspect}, :columns_down, 3) %>")
    assert_equal( "Zero   Four   Eight\n" +
                  "One    \e[34mFive\e[0m   Nine \n" +
                  "Two    Six  \n" +
                  "Three  Seven\n",
                  @output.string )

    colums_of_twenty = ["12345678901234567890"] * 5
    
    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{colums_of_twenty.inspect}, :columns_down) %>")
    assert_equal( "12345678901234567890  12345678901234567890  " +
                  "12345678901234567890\n" +
                  "12345678901234567890  12345678901234567890\n",
                  @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("<%= list(#{digits.inspect}, :columns_across, 3) %>")
    assert_equal( "Zero   One    Two  \n" +
                  "Three  Four   Five \n" + 
                  "Six    Seven  Eight\n" +
                  "Nine \n",
                  @output.string )
        
    colums_of_twenty.pop

    @output.truncate(@output.rewind)

    @terminal.say("<%= list( #{colums_of_twenty.inspect}, :columns_across ) %>")
    assert_equal( "12345678901234567890  12345678901234567890  " +
                  "12345678901234567890\n" +
                  "12345678901234567890\n",
                  @output.string )
  end
  
  def test_mode
    assert(%w[Win32API termios ncurses stty].include?(HighLine::CHARACTER_MODE))
  end
  
  class NameClass
    def self.parse( string )
      if string =~ /^\s*(\w+),\s*(\w+)\s+(\w+)\s*$/
        self.new($2, $3, $1)
      else
        raise ArgumentError, "Invalid name format."
      end
    end

    def initialize(first, middle, last)
      @first, @middle, @last = first, middle, last
    end
    
    attr_reader :first, :middle, :last
  end
  
  def test_my_class_conversion
    @input << "Gray, James Edward\n"
    @input.rewind

    answer = @terminal.ask("Your name?  ", NameClass) do |q|
      q.validate = lambda do |name|
        names = name.split(/,\s*/)
        return false unless names.size == 2
        return false if names.first =~ /\s/
        names.last.split.size == 2
      end
    end
    assert_instance_of(NameClass, answer)
    assert_equal("Gray", answer.last)
    assert_equal("James", answer.first)
    assert_equal("Edward", answer.middle)
  end
  
  def test_no_echo
    @input << "password\r"
    @input.rewind

    answer = @terminal.ask("Please enter your password:  ") do |q|
      q.echo = false
    end
    assert_equal("password", answer)
    assert_equal("Please enter your password:  \n", @output.string)

    @input.rewind
    @output.truncate(@output.rewind)
    
    answer = @terminal.ask("Pick a letter or number:  ") do |q|
      q.character = true
      q.echo      = false
    end
    assert_equal("p", answer)
    assert_equal("a", @input.getc.chr)
    assert_equal("Pick a letter or number:  \n", @output.string)
  end
  
  def test_paging
    @terminal.page_at = 22

    @input << "\n\n"
    @input.rewind

    @terminal.say((1..50).map { |n| "This is line #{n}.\n"}.join)
    assert_equal( (1..22).map { |n| "This is line #{n}.\n"}.join +
                  "\n-- press enter/return to continue or q to stop -- \n\n" +
                  (23..44).map { |n| "This is line #{n}.\n"}.join +
                  "\n-- press enter/return to continue or q to stop -- \n\n" +
                  (45..50).map { |n| "This is line #{n}.\n"}.join,
                  @output.string )
  end
  
  def test_range_requirements
    @input << "112\n-541\n28\n"
    @input.rewind

    answer = @terminal.ask("Tell me your age.", Integer) do |q|
      q.in = 0..105
    end
    assert_equal(28, answer)
    assert_equal( "Tell me your age.\n" +
                  "Your answer isn't within the expected range " +
                  "(included in 0..105).\n" +
                  "?  " +
                  "Your answer isn't within the expected range " +
                  "(included in 0..105).\n" +
                  "?  ", @output.string )

    @input.truncate(@input.rewind)
    @input << "1\n-541\n28\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Tell me your age.", Integer) do |q|
      q.above = 3
    end
    assert_equal(28, answer)
    assert_equal( "Tell me your age.\n" +
                  "Your answer isn't within the expected range " +
                  "(above 3).\n" +
                  "?  " +
                  "Your answer isn't within the expected range " +
                  "(above 3).\n" +
                  "?  ", @output.string )

    @input.truncate(@input.rewind)
    @input << "1\n28\n-541\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Lowest numer you can think of?", Integer) do |q|
      q.below = 0
    end
    assert_equal(-541, answer)
    assert_equal( "Lowest numer you can think of?\n" +
                  "Your answer isn't within the expected range " +
                  "(below 0).\n" +
                  "?  " +
                  "Your answer isn't within the expected range " +
                  "(below 0).\n" +
                  "?  ", @output.string )

    @input.truncate(@input.rewind)
    @input << "1\n-541\n6\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Enter a low even number:  ", Integer) do |q|
      q.above = 0
      q.below = 10
      q.in    = [2, 4, 6, 8]
    end
    assert_equal(6, answer)
    assert_equal( "Enter a low even number:  " +
                  "Your answer isn't within the expected range " +
                  "(above 0, below 10, and included in [2, 4, 6, 8]).\n" +
                  "?  " +
                  "Your answer isn't within the expected range " +
                  "(above 0, below 10, and included in [2, 4, 6, 8]).\n" +
                  "?  ", @output.string )
  end
  
  def test_reask
    number = 61676
    @input << "Junk!\n" << number << "\n"
    @input.rewind

    answer = @terminal.ask("Favorite number?  ", Integer)
    assert_kind_of(Integer, number)
    assert_instance_of(Fixnum, number)
    assert_equal(number, answer)
    assert_equal( "Favorite number?  " +
                  "You must enter a valid Integer.\n" +
                  "?  ", @output.string )

    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Favorite number?  ", Integer) do |q|
      q.responses[:ask_on_error] = :question
      q.responses[:invalid_type] = "Not a valid number!"
    end
    assert_kind_of(Integer, number)
    assert_instance_of(Fixnum, number)
    assert_equal(number, answer)
    assert_equal( "Favorite number?  " +
                  "Not a valid number!\n" +
                  "Favorite number?  ", @output.string )

    @input.truncate(@input.rewind)
    @input << "gen\ngene\n"
    @input.rewind
    @output.truncate(@output.rewind)

    answer = @terminal.ask("Select a mode:  ", [:generate, :gentle])
    assert_instance_of(Symbol, answer)
    assert_equal(:generate, answer)
    assert_equal( "Select a mode:  " +
                  "Ambiguous choice.  " +
                  "Please choose one of [:generate, :gentle].\n" +
                  "?  ", @output.string )
  end
  
  def test_response_embedding
    @input << "112\n-541\n28\n"
    @input.rewind

    answer = @terminal.ask("Tell me your age.", Integer) do |q|
      q.in = 0..105
      q.responses[:not_in_range] = "Need a <%= @question.answer_type %>" +
                                   " <%= @question.expected_range %>."
    end
    assert_equal(28, answer)
    assert_equal( "Tell me your age.\n" +
                  "Need a Integer included in 0..105.\n" +
                  "?  " +
                  "Need a Integer included in 0..105.\n" +
                  "?  ", @output.string )
  end
  
  def test_say
    @terminal.say("This will have a newline.")
    assert_equal("This will have a newline.\n", @output.string)

    @output.truncate(@output.rewind)

    @terminal.say("This will also have one newline.\n")
    assert_equal("This will also have one newline.\n", @output.string)

    @output.truncate(@output.rewind)

    @terminal.say("This will not have a newline.  ")
    assert_equal("This will not have a newline.  ", @output.string)
  end

  def test_type_conversion
    number = 61676
    @input << number << "\n"
    @input.rewind

    answer = @terminal.ask("Favorite number?  ", Integer)
    assert_kind_of(Integer, answer)
    assert_instance_of(Fixnum, answer)
    assert_equal(number, answer)
    
    @input.truncate(@input.rewind)
    number = 1_000_000_000_000_000_000_000_000_000_000
    @input << number << "\n"
    @input.rewind

    answer = @terminal.ask("Favorite number?  ", Integer)
    assert_kind_of(Integer, answer)
    assert_instance_of(Bignum, answer)
    assert_equal(number, answer)

    @input.truncate(@input.rewind)
    number = 10.5002
    @input << number << "\n"
    @input.rewind

    answer = @terminal.ask( "Favorite number?  ",
                            lambda { |n| n.to_f.abs.round } )
    assert_kind_of(Integer, answer)
    assert_instance_of(Fixnum, answer)
    assert_equal(11, answer)

    @input.truncate(@input.rewind)
    animal = :dog
    @input << animal << "\n"
    @input.rewind

    answer = @terminal.ask("Favorite animal?  ", Symbol)
    assert_instance_of(Symbol, answer)
    assert_equal(animal, answer)

    @input.truncate(@input.rewind)
    @input << "16th June 1976\n"
    @input.rewind

    answer = @terminal.ask("Enter your birthday.", Date)
    assert_instance_of(Date, answer)
    assert_equal(16, answer.day)
    assert_equal(6, answer.month)
    assert_equal(1976, answer.year)

    @input.truncate(@input.rewind)
    pattern = "^yes|no$"
    @input << pattern << "\n"
    @input.rewind

    answer = @terminal.ask("Give me a pattern to match with:  ", Regexp)
    assert_instance_of(Regexp, answer)
    assert_equal(/#{pattern}/, answer)

    @input.truncate(@input.rewind)
    @input << "gen\n"
    @input.rewind

    answer = @terminal.ask("Select a mode:  ", [:generate, :run])
    assert_instance_of(Symbol, answer)
    assert_equal(:generate, answer)
  end
  
  def test_validation
    @input << "system 'rm -rf /'\n105\n0b101_001\n"
    @input.rewind

    answer = @terminal.ask("Enter a binary number:  ") do |q|
      q.validate = /\A(?:0b)?[01_]+\Z/
    end
    assert_equal("0b101_001", answer)
    assert_equal( "Enter a binary number:  " +
                  "Your answer isn't valid " +
                  "(must match /\\A(?:0b)?[01_]+\\Z/).\n" +
                  "?  " +
                  "Your answer isn't valid " +
                  "(must match /\\A(?:0b)?[01_]+\\Z/).\n" +
                  "?  ", @output.string )

    @input.truncate(@input.rewind)
    @input << "Gray II, James Edward\n" +
              "Gray, Dana Ann Leslie\n" +
              "Gray, James Edward\n"
    @input.rewind

    answer = @terminal.ask("Your name?  ") do |q|
      q.validate = lambda do |name|
        names = name.split(/,\s*/)
        return false unless names.size == 2
        return false if names.first =~ /\s/
        names.last.split.size == 2
      end
    end
    assert_equal("Gray, James Edward", answer)
  end
  
  def test_whitespace
    @input << "  A   lot\tof  \t  space\t  \there!   \n"
    @input.rewind
    
    answer = @terminal.ask("Enter a whitespace filled string:  ") do |q|
      q.whitespace = :chomp
    end
    assert_equal("  A   lot\tof  \t  space\t  \there!   ", answer)

    @input.rewind

    answer = @terminal.ask("Enter a whitespace filled string:  ")
    assert_equal("A   lot\tof  \t  space\t  \there!", answer)

    @input.rewind

    answer = @terminal.ask("Enter a whitespace filled string:  ") do |q|
      q.whitespace = :strip_and_collapse
    end
    assert_equal("A lot of space here!", answer)

    @input.rewind

    answer = @terminal.ask("Enter a whitespace filled string:  ") do |q|
      q.whitespace = :remove
    end
    assert_equal("Alotofspacehere!", answer)

    @input.rewind

    answer = @terminal.ask("Enter a whitespace filled string:  ") do |q|
      q.whitespace = :none
    end
    assert_equal("  A   lot\tof  \t  space\t  \there!   \n", answer)
  end
  
  def test_wrap
    @terminal.wrap_at = 80
    
    @terminal.say("This is a very short line.")
    assert_equal("This is a very short line.\n", @output.string)
    
    @output.truncate(@output.rewind)

    @terminal.say( "This is a long flowing paragraph meant to span " +
                   "several lines.  This text should definitely be " +
                   "wrapped at the set limit, in the result.  Your code " +
                   "does well with things like this.\n\n" +
                   "  * This is a simple embedded list.\n" +
                   "  * You're code should not mess with this...\n" +
                       "  * Because it's already formatted correctly and " +
                   "does not\n" +
                   "    exceed the limit!" )
    assert_equal( "This is a long flowing paragraph meant to span " +
                  "several lines.  This text should\n" +
                  "definitely be wrapped at the set limit, in the " +
                  "result.  Your code does well with\n" +
                  "things like this.\n\n" +
                  "  * This is a simple embedded list.\n" +
                  "  * You're code should not mess with this...\n" +
                  "  * Because it's already formatted correctly and does " +
                  "not\n" +
                  "    exceed the limit!\n", @output.string )

    @output.truncate(@output.rewind)

    @terminal.say("-=" * 50)
    assert_equal(("-=" * 40 + "\n") + ("-=" * 10 + "\n"), @output.string)
  end
  
  def test_track_eof
    assert_raise(EOFError) { @terminal.ask("Any input left?  ") }
    
    # turn EOF tracking
    old_setting = HighLine.track_eof?
    assert_nothing_raised(Exception) { HighLine.track_eof = false }
    begin
      @terminal.ask("And now?  ")  # this will still blow up, nothing available
    rescue
      assert_not_equal(EOFError, $!.class)  # but HighLine's safe guards are off
    end
    HighLine.track_eof = old_setting
  end
  
  def test_version
    assert_not_nil(HighLine::VERSION)
    assert_instance_of(String, HighLine::VERSION)
    assert(HighLine::VERSION.frozen?)
    assert_match(/\A\d\.\d\.\d\Z/, HighLine::VERSION)
  end
end
