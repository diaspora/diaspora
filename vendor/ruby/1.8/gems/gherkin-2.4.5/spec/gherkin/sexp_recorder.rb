require 'gherkin/rubify'
require 'gherkin/formatter/model'

module Gherkin
  class SexpRecorder
    include Rubify
    
    def initialize
      @sexps = []
    end

    # We can't use method_missing - therubyracer isn't able to invoke methods like that.
    [:comment, :tag, :feature, :background, :scenario, :scenario_outline, :examples, :step, :doc_string, :row, :eof, :uri, :syntax_error].each do |event|
      define_method(event) do |*args|
        event = :scenario_outline if event == :scenarioOutline # Special Java Lexer handling
        event = :doc_string if event == :docString # Special Java Lexer handling
        event = :syntax_error if event == :syntaxError # Special Java Lexer handling
        args  = rubify(args)
        args  = sexpify(args)
        @sexps << [event] + args
      end
    end

    def to_sexp
      @sexps
    end

    # Useful in IRB
    def reset!
      @sexps = []
    end

    def errors
      @sexps.select { |sexp| sexp[0] == :syntax_error }
    end

    def line(number)
      @sexps.find { |sexp| sexp.last == number }
    end

    def sexpify(o)
      array = (defined?(JRUBY_VERSION) && Java.java.util.Collection === o) || 
              (defined?(V8) && V8::Array === o) ||
              Array === o
      if array
        o.map{|e| sexpify(e)}
      elsif(Formatter::Model::Row === o)
        {
          "cells" => sexpify(o.cells),
          "comments" => sexpify(o.comments),
          "line" => o.line,
        }
      elsif(Formatter::Model::Comment === o)
        o.value
      elsif(Formatter::Model::Tag === o)
        o.name
      else
        o
      end
    end
  end
end
