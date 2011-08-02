module Nokogiri
  module LibXML # :nodoc:

    class XmlXpathObject < FFI::ManagedStruct # :nodoc:

      XPATH_UNDEFINED = 0
      XPATH_NODESET = 1
      XPATH_BOOLEAN = 2
      XPATH_NUMBER = 3
      XPATH_STRING = 4
      XPATH_POINT = 5
      XPATH_RANGE = 6
      XPATH_LOCATIONSET = 7
      XPATH_USERS = 8
      XPATH_XSLT_TREE = 9

      layout(
        :type,          :int,
        :nodesetval,    :pointer,
        :boolval,       :int,
        :floatval,      :double,
        :stringval,     :string,
        :user,          :pointer,
        :index,         :int,
        :user2,         :pointer,
        :index2,        :int
        )

      def self.release ptr
        LibXML.xmlXPathFreeNodeSetList(ptr) # despite the name, this frees the xpath but not the contained node set
      end
    end

  end
end
