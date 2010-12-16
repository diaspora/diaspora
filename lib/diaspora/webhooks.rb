#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Webhooks
    require 'builder/xchar'

    def to_diaspora_xml
      xml = "<XML>"
      xml += "<post>#{to_xml.to_s}</post>"
      xml += "</XML>"
    end
  
    def x(input)
      input.to_s.to_xs
    end
  end
end
