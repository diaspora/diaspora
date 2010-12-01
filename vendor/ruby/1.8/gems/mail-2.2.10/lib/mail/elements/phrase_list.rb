# encoding: utf-8
module Mail
  class PhraseList
    
    include Mail::Utilities
    
    def initialize(string)
      parser = Mail::PhraseListsParser.new
      if tree = parser.parse(string)
        @phrases = tree.phrases
      else
        raise Mail::Field::ParseError, "PhraseList can not parse |#{string}|\nReason was: #{parser.failure_reason}\n"
      end
    end
    
    def phrases
      @phrases.map { |p| unquote(p.text_value) }
    end

  end
end