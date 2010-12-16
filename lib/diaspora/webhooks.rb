#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Webhooks

    def to_diaspora_xml
      xml = "<XML>"
      xml += "<post>#{to_xml.to_s}</post>"
      xml += "</XML>"
    end

    def x(input)
      result.gsub!(/[&<>'"]/) do | match |
        case match
        when '&' then return '&amp;'
        when '<' then return '&lt;'
        when '>' then return '&gt;'
        when "'" then return '&apos;'
        when '"' then return '&quote;'
        end
      end
      return result
    end
  end
end
