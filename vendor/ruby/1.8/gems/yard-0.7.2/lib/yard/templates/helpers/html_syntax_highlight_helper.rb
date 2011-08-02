module YARD
  module Templates
    module Helpers
      # Helper methods for syntax highlighting.
      module HtmlSyntaxHighlightHelper
        # Highlights Ruby source
        # @param [String] source the Ruby source code
        # @return [String] the highlighted Ruby source
        def html_syntax_highlight_ruby(source)
          if Parser::SourceParser.parser_type == :ruby
            html_syntax_highlight_ruby_ripper(source)
          else
            html_syntax_highlight_ruby_legacy(source)
          end
        end

        private

        def html_syntax_highlight_ruby_ripper(source)
          tokenlist = Parser::Ruby::RubyParser.parse(source, "(syntax_highlight)").tokens
          output = ""
          tokenlist.each do |s|
            output << "<span class='tstring'>" if [:tstring_beg, :regexp_beg].include?(s[0])
            case s.first
            when :nl, :ignored_nl, :sp
              output << h(s.last)
            when :ident
              output << "<span class='id #{h(s.last)}'>#{h(s.last)}</span>"
            else
              output << "<span class='#{s.first}'>#{h(s.last)}</span>"
            end
            output << "</span>" if [:tstring_end, :regexp_end].include?(s[0])
          end
          output
        rescue Parser::ParserSyntaxError
          h(source)
        end

        def html_syntax_highlight_ruby_legacy(source)
          tokenlist = Parser::Ruby::Legacy::TokenList.new(source)
          tokenlist.map do |s|
            prettyclass = s.class.class_name.sub(/^Tk/, '').downcase
            prettysuper = s.class.superclass.class_name.sub(/^Tk/, '').downcase

            case s
            when Parser::Ruby::Legacy::RubyToken::TkWhitespace, Parser::Ruby::Legacy::RubyToken::TkUnknownChar
              h s.text
            when Parser::Ruby::Legacy::RubyToken::TkId
              prettyval = h(s.text)
              "<span class='#{prettyval} #{prettyclass} #{prettysuper}'>#{prettyval}</span>"
            else
              "<span class='#{prettyclass} #{prettysuper}'>#{h s.text}</span>"
            end
          end.join
        end
      end
    end
  end
end