##
## $Release: 2.6.6 $
## copyright(c) 2006-2010 kuwata-lab.com all rights reserved.
##

require 'erubis/engine'
require 'erubis/enhancer'


module Erubis


  module JavaGenerator
    include Generator

    def self.supported_properties()   # :nodoc:
      return [
              [:indent,   '',       "indent spaces (ex. '  ')"],
              [:buf,      '_buf',   "output buffer name"],
              [:bufclass, 'StringBuffer', "output buffer class (ex. 'StringBuilder')"],
            ]
    end

    def init_generator(properties={})
      super
      @escapefunc ||= 'escape'
      @indent = properties[:indent] || ''
      @buf = properties[:buf] || '_buf'
      @bufclass = properties[:bufclass] || 'StringBuffer'
    end

    def add_preamble(src)
      src << "#{@indent}#{@bufclass} #{@buf} = new #{@bufclass}();"
    end

    def escape_text(text)
      @@table_ ||= { "\r"=>"\\r", "\n"=>"\\n", "\t"=>"\\t", '"'=>'\\"', "\\"=>"\\\\" }
      return text.gsub!(/[\r\n\t"\\]/) { |m| @@table_[m] } || text
    end

    def add_text(src, text)
      return if text.empty?
      src << (src.empty? || src[-1] == ?\n ? @indent : ' ')
      src << @buf << ".append("
      i = 0
      text.each_line do |line|
        src << "\n" << @indent << '          + ' if i > 0
        i += 1
        src << '"' << escape_text(line) << '"'
      end
      src << ");" << (text[-1] == ?\n ? "\n" : "")
    end

    def add_stmt(src, code)
      src << code
    end

    def add_expr_literal(src, code)
      src << @indent if src.empty? || src[-1] == ?\n
      code.strip!
      src << " #{@buf}.append(#{code});"
    end

    def add_expr_escaped(src, code)
      add_expr_literal(src, escaped_expr(code))
    end

    def add_expr_debug(src, code)
      code.strip!
      src << @indent if src.empty? || src[-1] == ?\n
      src << " System.err.println(\"*** debug: #{code}=\"+(#{code}));"
    end

    def add_postamble(src)
      src << "\n" if src[-1] == ?;
      src << @indent << "return " << @buf << ".toString();\n"
      #src << @indent << "System.out.print(" << @buf << ".toString());\n"
    end

  end


  ##
  ## engine for Java
  ##
  class Ejava < Basic::Engine
    include JavaGenerator
  end


  class EscapedEjava < Ejava
    include EscapeEnhancer
  end


  #class XmlEjava < Ejava
  #  include EscapeEnhancer
  #end

  class PI::Ejava < PI::Engine
    include JavaGenerator

    def init_converter(properties={})
      @pi = 'java'
      super(properties)
    end

  end

end
