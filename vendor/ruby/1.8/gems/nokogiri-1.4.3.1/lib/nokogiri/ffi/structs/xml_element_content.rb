# :stopdoc:
module Nokogiri
  module LibXML
    class XmlElementContent < FFI::Struct
      layout(
        :type,  :int,
        :ocur,  :int, # This is misspelled in the header file
        :name,  :string,
        :c1,    :pointer,
        :c2,    :pointer,
        :parent,:pointer,
        :prefix,:string
      )
    end
  end
end
# :startdoc:
