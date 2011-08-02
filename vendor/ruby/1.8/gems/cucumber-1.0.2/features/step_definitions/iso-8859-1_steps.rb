# encoding: iso-8859-1
# Ideally we would use Norwegian keywords here, but that won't work unless this file is UTF-8 encoded.
# Alternatively it would be possible to use Norwegian keywords and encode the file as UTF-8.
# 
# In both cases, stepdef arguments will be sent in as UTF-8, regardless of what encoding is used.
Given /^jeg drikker en "([^"]*)"$/ do |drink|
  drink.should == utf8('øl', 'iso-8859-1')
end

When /^skal de andre si "([^"]*)"$/ do |greeting|
  greeting.should == utf8('skål', 'iso-8859-1')
end

module EncodingHelper
  def utf8(string, encoding)
    if string.respond_to?(:encode) # Ruby 1.9
      string.encode('UTF-8')
    else # Ruby 1.8
      require 'iconv'
      Iconv.new('UTF-8', encoding).iconv(string)
    end
  end
end
World(EncodingHelper)