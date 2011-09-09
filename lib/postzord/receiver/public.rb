#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
module Postzord
  class Receiver
    class Public
      attr_accessor :xml

      def initialize(xml)
        @xml = xml
        
      end
    end
  end
end
