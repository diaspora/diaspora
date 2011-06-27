#   Copyright (c) 2011, David Morley.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#   Modified by Dis McCarthy for Privit.us

module Shorty
  def self.swap(message)
    require 'rubygems'
    require 'cgi'
    require 'lib/isgd'
    message.gsub!(/( |^)(www\.[^\s]+\.[^\s])/, '\1http://\2')
    message.gsub!(/(<a target="\\?_blank" href=")?(https|http|ftp):\/\/\/([^\s]+)/) do |m|
      if !$1.nil?
        m
      else
        oldurl = "#{$2}://#{$3}"
        newurl = IsGd::shorten(oldurl)
        res = %{#{newurl}}
	if oldurl.length > newurl.length
	  res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
          res
        else
	  oldurl
        end
      end
    end
    return message
  end
end

