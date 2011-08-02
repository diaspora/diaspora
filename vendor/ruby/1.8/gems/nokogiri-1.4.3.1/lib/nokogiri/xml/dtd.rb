module Nokogiri
  module XML
    class DTD < Nokogiri::XML::Node
      undef_method :attribute_nodes
      undef_method :content
      undef_method :namespace
      undef_method :namespace_definitions
      undef_method :line
    end
  end
end
