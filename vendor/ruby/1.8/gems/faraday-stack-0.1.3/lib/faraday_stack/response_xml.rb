module FaradayStack
  class ResponseXML < ResponseMiddleware
    dependency do
      require 'nokogiri'
      Nokogiri::XML
    end
    
    define_parser do |body|
      Nokogiri::XML body
    end
  end
end
