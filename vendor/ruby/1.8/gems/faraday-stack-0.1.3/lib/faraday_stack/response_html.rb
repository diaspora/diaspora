module FaradayStack
  class ResponseHTML < ResponseMiddleware
    dependency do
      require 'nokogiri'
      Nokogiri::HTML
    end
    
    define_parser do |body|
      Nokogiri::HTML body
    end
  end
end
