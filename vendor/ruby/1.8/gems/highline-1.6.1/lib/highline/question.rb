#!/usr/local/bin/ruby -w

# question.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.
 
require "optparse"
require "date"
require "pathname"

class HighLine
  #
  # Question objects contain all the details of a single invocation of
  # HighLine.ask().  The object is initialized by the parameters passed to
  # HighLine.ask() and then queried to make sure each step of the input
  # process is handled according to the users wishes.
  #
  class Question
    # An internal HighLine error.  User code does not need to trap this.
    class NoAutoCompleteMatch < StandardError
      # do nothing, just creating a unique error type
    end

    #
    # Create an instance of HighLine::Question.  Expects a _question_ to ask
    # (can be <tt>""</tt>) and an _answer_type_ to convert the answer to.
    # The _answer_type_ parameter must be a type recognized by
    # Question.convert(). If given, a block is yeilded the new Question
    # object to allow custom initializaion.
    #
    def initialize( question, answer_type )
      # initialize instance data
      @question    = question
      @answer_type = answer_type
      
      @character    = nil
      @limit        = nil
      @echo         = true
      @readline     = false
      @whitespace   = :strip
      @case         = nil
      @default      = nil
      @validate     = nil
      @above        = nil
      @below        = nil
      @in           = nil
      @confirm      = nil
      @gather       = false
      @first_answer = nil
      @directory    = Pathname.new(File.expand_path(File.dirname($0)))
      @glob         = "*"
      @responses    = Hash.new
      @overwrite    = false
      
      # allow block to override settings
      yield self if block_given?

      # finalize responses based on settings
      build_responses
    end
    
    # The ERb template of the question to be asked.
    attr_accessor :question
    # The type that will be used to convert this answer.
    attr_accessor :answer_type
    #
    # Can be set to +true+ to use HighLine's cross-platform character reader
    # instead of fetching an entire line of input.  (Note: HighLine's character
    # reader *ONLY* supports STDIN on Windows and Unix.)  Can also be set to
    # <tt>:getc</tt> to use that method on the input stream.
    #
    # *WARNING*:  The _echo_ and _overwrite_ attributes for a question are 
    # ignored when using the <tt>:getc</tt> method.  
    # 
    attr_accessor :character
    #
    # Allows you to set a character limit for input.
    # 
    # *WARNING*:  This option forces a character by character read.
    # 
    attr_accessor :limit
    #
    # Can be set to +true+ or +false+ to control whether or not input will
    # be echoed back to the user.  A setting of +true+ will cause echo to
    # match input, but any other true value will be treated as to String to
    # echo for each character typed.
    # 
    # This requires HighLine's character reader.  See the _character_
    # attribute for details.
    # 
    # *Note*:  When using HighLine to manage echo on Unix based systems, we
    # recommend installing the termios gem.  Without it, it's possible to type
    # fast enough to have letters still show up (when reading character by
    # character only).
    #
    attr_accessor :echo
    #
    # Use the Readline library to fetch input.  This allows input editing as
    # well as keeping a history.  In addition, tab will auto-complete 
    # within an Array of choices or a file listing.
    # 
    # *WARNING*:  This option is incompatible with all of HighLine's 
    # character reading  modes and it causes HighLine to ignore the
    # specified _input_ stream.
    # 
    attr_accessor :readline
    #
    # Used to control whitespace processing for the answer to this question.
    # See HighLine::Question.remove_whitespace() for acceptable settings.
    #
    attr_accessor :whitespace
    #
    # Used to control character case processing for the answer to this question.
    # See HighLine::Question.change_case() for acceptable settings.
    #
    attr_accessor :case
    # Used to provide a default answer to this question.
    attr_accessor :default
    #
    # If set to a Regexp, the answer must match (before type conversion).
    # Can also be set to a Proc which will be called with the provided
    # answer to validate with a +true+ or +false+ return.
    #
    attr_accessor :validate
    # Used to control range checks for answer.
    attr_accessor :above, :below
    # If set, answer must pass an include?() check on this object.
    attr_accessor :in
    #
    # Asks a yes or no confirmation question, to ensure a user knows what
    # they have just agreed to.  If set to +true+ the question will be,
    # "Are you sure?  "  Any other true value for this attribute is assumed
    # to be the question to ask.  When +false+ or +nil+ (the default), 
    # answers are not confirmed.
    # 
    attr_accessor :confirm
    #
    # When set, the user will be prompted for multiple answers which will
    # be collected into an Array or Hash and returned as the final answer.
    # 
    # You can set _gather_ to an Integer to have an Array of exactly that
    # many answers collected, or a String/Regexp to match an end input which
    # will not be returned in the Array.
    # 
    # Optionally _gather_ can be set to a Hash.  In this case, the question
    # will be asked once for each key and the answers will be returned in a
    # Hash, mapped by key.  The <tt>@key</tt> variable is set before each 
    # question is evaluated, so you can use it in your question.
    # 
    attr_accessor :gather
    # 
    # When set to a non *nil* value, this will be tried as an answer to the
    # question.  If this answer passes validations, it will become the result
    # without the user ever being prompted.  Otherwise this value is discarded, 
    # and this Question is resolved as a normal call to HighLine.ask().
    # 
    attr_writer :first_answer
    #
    # The directory from which a user will be allowed to select files, when
    # File or Pathname is specified as an _answer_type_.  Initially set to
    # <tt>Pathname.new(File.expand_path(File.dirname($0)))</tt>.
    # 
    attr_accessor :directory
    # 
    # The glob pattern used to limit file selection when File or Pathname is
    # specified as an _answer_type_.  Initially set to <tt>"*"</tt>.
    # 
    attr_accessor :glob
    #
    # A Hash that stores the various responses used by HighLine to notify
    # the user.  The currently used responses and their purpose are as
    # follows:
    #
    # <tt>:ambiguous_completion</tt>::  Used to notify the user of an
    #                                   ambiguous answer the auto-completion
    #                                   system cannot resolve.
    # <tt>:ask_on_error</tt>::          This is the question that will be
    #                                   redisplayed to the user in the event
    #                                   of an error.  Can be set to
    #                                   <tt>:question</tt> to repeat the
    #                                   original question.
    # <tt>:invalid_type</tt>::          The error message shown when a type
    #                                   conversion fails.
    # <tt>:no_completion</tt>::         Used to notify the user that their
    #                                   selection does not have a valid
    #                                   auto-completion match.
    # <tt>:not_in_range</tt>::          Used to notify the user that a
    #                                   provided answer did not satisfy
    #                                   the range requirement tests.
    # <tt>:not_valid</tt>::             The error message shown when
    #                                   validation checks fail.
    #
    attr_reader :responses
    #
    # When set to +true+ the question is asked, but output does not progress to
    # the next line.  The Cursor is moved back to the beginning of the question
    # line and it is cleared so that all the contents of the line disappear from
    # the screen.
    #
    attr_accessor :overwrite
   
    #
    # Returns the provided _answer_string_ or the default answer for this
    # Question if a default was set and the answer is empty.
    #
    def answer_or_default( answer_string )
      if answer_string.length == 0 and not @default.nil?
        @default
      else
        answer_string
      end
    end
    
    #
    # Called late in the initialization process to build intelligent
    # responses based on the details of this Question object.
    #
    def build_responses(  )
      ### WARNING:  This code is quasi-duplicated in     ###
      ### Menu.update_responses().  Check there too when ###
      ### making changes!                                ###
      append_default unless default.nil?
      @responses = { :ambiguous_completion =>
                       "Ambiguous choice.  " +
                       "Please choose one of #{@answer_type.inspect}.",
                     :ask_on_error         =>
                       "?  ",
                     :invalid_type         =>
                       "You must enter a valid #{@answer_type}.",
                     :no_completion        =>
                       "You must choose one of " +
                       "#{@answer_type.inspect}.",
                     :not_in_range         =>
                       "Your answer isn't within the expected range " +
                       "(#{expected_range}).",
                     :not_valid            =>
                       "Your answer isn't valid (must match " +
                       "#{@validate.inspect})." }.merge(@responses)
      ### WARNING:  This code is quasi-duplicated in     ###
      ### Menu.update_responses().  Check there too when ###
      ### making changes!                                ###
    end
    
    #
    # Returns the provided _answer_string_ after changing character case by
    # the rules of this Question.  Valid settings for whitespace are:
    #
    # +nil+::                        Do not alter character case. 
    #                                (Default.)
    # <tt>:up</tt>::                 Calls upcase().
    # <tt>:upcase</tt>::             Calls upcase().
    # <tt>:down</tt>::               Calls downcase().
    # <tt>:downcase</tt>::           Calls downcase().
    # <tt>:capitalize</tt>::         Calls capitalize().
    # 
    # An unrecognized choice (like <tt>:none</tt>) is treated as +nil+.
    # 
    def change_case( answer_string )
      if [:up, :upcase].include?(@case)
        answer_string.upcase
      elsif [:down, :downcase].include?(@case)
        answer_string.downcase
      elsif @case == :capitalize
        answer_string.capitalize
      else
        answer_string
      end
    end

    #
    # Transforms the given _answer_string_ into the expected type for this
    # Question.  Currently supported conversions are:
    #
    # <tt>[...]</tt>::         Answer must be a member of the passed Array. 
    #                          Auto-completion is used to expand partial
    #                          answers.
    # <tt>lambda {...}</tt>::  Answer is passed to lambda for conversion.
    # Date::                   Date.parse() is called with answer.
    # DateTime::               DateTime.parse() is called with answer.
    # File::                   The entered file name is auto-completed in 
    #                          terms of _directory_ + _glob_, opened, and
    #                          returned.
    # Float::                  Answer is converted with Kernel.Float().
    # Integer::                Answer is converted with Kernel.Integer().
    # +nil+::                  Answer is left in String format.  (Default.)
    # Pathname::               Same as File, save that a Pathname object is
    #                          returned.
    # String::                 Answer is converted with Kernel.String().
    # Regexp::                 Answer is fed to Regexp.new().
    # Symbol::                 The method to_sym() is called on answer and
    #                          the result returned.
    # <i>any other Class</i>:: The answer is passed on to
    #                          <tt>Class.parse()</tt>.
    #
    # This method throws ArgumentError, if the conversion cannot be
    # completed for any reason.
    # 
    def convert( answer_string )
      if @answer_type.nil?
        answer_string
      elsif [Float, Integer, String].include?(@answer_type)
        Kernel.send(@answer_type.to_s.to_sym, answer_string)
      elsif @answer_type == Symbol
        answer_string.to_sym
      elsif @answer_type == Regexp
        Regexp.new(answer_string)
      elsif @answer_type.is_a?(Array) or [File, Pathname].include?(@answer_type)
        # cheating, using OptionParser's Completion module
        choices = selection
        choices.extend(OptionParser::Completion)
        answer = choices.complete(answer_string)
        if answer.nil?
          raise NoAutoCompleteMatch
        end
        if @answer_type.is_a?(Array)
          answer.last
        elsif @answer_type == File
          File.open(File.join(@directory.to_s, answer.last))
        else
          Pathname.new(File.join(@directory.to_s, answer.last))
        end
      elsif [Date, DateTime].include?(@answer_type) or @answer_type.is_a?(Class)
        @answer_type.parse(answer_string)
      elsif @answer_type.is_a?(Proc)
        @answer_type[answer_string]
      end
    end

    # Returns a english explination of the current range settings.
    def expected_range(  )
      expected = [ ]

      expected << "above #{@above}" unless @above.nil?
      expected << "below #{@below}" unless @below.nil?
      expected << "included in #{@in.inspect}" unless @in.nil?

      case expected.size
      when 0 then ""
      when 1 then expected.first
      when 2 then expected.join(" and ")
      else        expected[0..-2].join(", ") + ", and #{expected.last}"
      end
    end

    # Returns _first_answer_, which will be unset following this call.
    def first_answer( )
      @first_answer
    ensure
      @first_answer = nil
    end
    
    # Returns true if _first_answer_ is set.
    def first_answer?( )
      not @first_answer.nil?
    end
    
    #
    # Returns +true+ if the _answer_object_ is greater than the _above_
    # attribute, less than the _below_ attribute and included?()ed in the
    # _in_ attribute.  Otherwise, +false+ is returned.  Any +nil+ attributes
    # are not checked.
    #
    def in_range?( answer_object )
      (@above.nil? or answer_object > @above) and
      (@below.nil? or answer_object < @below) and
      (@in.nil? or @in.include?(answer_object))
    end
    
    #
    # Returns the provided _answer_string_ after processing whitespace by
    # the rules of this Question.  Valid settings for whitespace are:
    #
    # +nil+::                        Do not alter whitespace.
    # <tt>:strip</tt>::              Calls strip().  (Default.)
    # <tt>:chomp</tt>::              Calls chomp().
    # <tt>:collapse</tt>::           Collapses all whitspace runs to a
    #                                single space.
    # <tt>:strip_and_collapse</tt>:: Calls strip(), then collapses all
    #                                whitspace runs to a single space.
    # <tt>:chomp_and_collapse</tt>:: Calls chomp(), then collapses all
    #                                whitspace runs to a single space.
    # <tt>:remove</tt>::             Removes all whitespace.
    # 
    # An unrecognized choice (like <tt>:none</tt>) is treated as +nil+.
    # 
    # This process is skipped, for single character input.
    # 
    def remove_whitespace( answer_string )
      if @whitespace.nil?
        answer_string
      elsif [:strip, :chomp].include?(@whitespace)
        answer_string.send(@whitespace)
      elsif @whitespace == :collapse
        answer_string.gsub(/\s+/, " ")
      elsif [:strip_and_collapse, :chomp_and_collapse].include?(@whitespace)
        result = answer_string.send(@whitespace.to_s[/^[a-z]+/])
        result.gsub(/\s+/, " ")
      elsif @whitespace == :remove
        answer_string.gsub(/\s+/, "")
      else
        answer_string
      end
    end

    #
    # Returns an Array of valid answers to this question.  These answers are
    # only known when _answer_type_ is set to an Array of choices, File, or
    # Pathname.  Any other time, this method will return an empty Array.
    # 
    def selection(  )
      if @answer_type.is_a?(Array)
        @answer_type
      elsif [File, Pathname].include?(@answer_type)
        Dir[File.join(@directory.to_s, @glob)].map do |file|
          File.basename(file)
        end
      else
        [ ]
      end      
    end
    
    # Stringifies the question to be asked.
    def to_str(  )
      @question
    end

    #
    # Returns +true+ if the provided _answer_string_ is accepted by the 
    # _validate_ attribute or +false+ if it's not.
    # 
    # It's important to realize that an answer is validated after whitespace
    # and case handling.
    #
    def valid_answer?( answer_string )
      @validate.nil? or 
      (@validate.is_a?(Regexp) and answer_string =~ @validate) or
      (@validate.is_a?(Proc)   and @validate[answer_string])
    end
    
    private
    
    #
    # Adds the default choice to the end of question between <tt>|...|</tt>.
    # Trailing whitespace is preserved so the function of HighLine.say() is
    # not affected.
    #
    def append_default(  )
      if @question =~ /([\t ]+)\Z/
        @question << "|#{@default}|#{$1}"
      elsif @question == ""
        @question << "|#{@default}|  "
      elsif @question[-1, 1] == "\n"
        @question[-2, 0] =  "  |#{@default}|"
      else
        @question << "  |#{@default}|"
      end
    end
  end
end
