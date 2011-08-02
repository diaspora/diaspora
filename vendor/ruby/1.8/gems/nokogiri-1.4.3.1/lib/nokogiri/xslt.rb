require 'nokogiri/xslt/stylesheet'

module Nokogiri
  class << self
    ###
    # Create a Nokogiri::XSLT::Stylesheet with +stylesheet+.
    #
    # Example:
    #
    #   xslt = Nokogiri::XSLT(File.read(ARGV[0]))
    #
    def XSLT stylesheet
      XSLT.parse(stylesheet)
    end
  end

  ###
  # See Nokogiri::XSLT::Stylesheet for creating and maniuplating
  # Stylesheet object.
  module XSLT
    class << self
      ###
      # Parse the stylesheet in +string+
      def parse string
        Stylesheet.parse_stylesheet_doc(XML.parse(string))
      end
      
      ###
      # Quote parameters in +params+ for stylesheet safety
      def quote_params params
        parray = (params.instance_of?(Hash) ? params.to_a.flatten : params).dup
        parray.each_with_index do |v,i|
          if i % 2 > 0
            parray[i]=
              if v =~ /'/
                "concat('#{ v.gsub(/'/, %q{', "'", '}) }')"
              else
                "'#{v}'";
              end
          else
            parray[i] = v.to_s
          end
        end
        parray.flatten
      end
    end
  end
end
