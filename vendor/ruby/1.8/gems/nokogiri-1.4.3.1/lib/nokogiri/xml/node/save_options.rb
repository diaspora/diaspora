module Nokogiri
  module XML
    class Node
      ###
      # Save options for serializing nodes
      class SaveOptions
        # Format serialized xml
        FORMAT          = 1
        # Do not include delcarations
        NO_DECLARATION  = 2
        # Do not include empty tags
        NO_EMPTY_TAGS   = 4
        # Do not save XHTML
        NO_XHTML        = 8
        # Save as XHTML
        AS_XHTML        = 16
        # Save as XML
        AS_XML          = 32
        # Save as HTML
        AS_HTML         = 64

        # Integer representation of the SaveOptions
        attr_reader :options

        # Create a new SaveOptions object with +options+
        def initialize options = 0; @options = options; end
        constants.each do |constant|
          class_eval %{
            def #{constant.downcase}
              @options |= #{constant}
              self
            end

            def #{constant.downcase}?
              #{constant} & @options == #{constant}
            end
          }
        end
      end
    end
  end
end
