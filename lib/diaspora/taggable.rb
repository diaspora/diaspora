#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Taggable
    VALID_TAG_BODY = /[^_,\s#*\[\]()\@\/"'\.%]+\b/

    def self.included(model)
      model.class_eval do
        cattr_accessor :field_with_tags
      end
      model.instance_eval do
        def extract_tags_from sym
          self.field_with_tags = sym
        end
        def field_with_tags_setter
          "#{self.field_with_tags}=".to_sym
        end
      end
    end

    def build_tags
      self.tag_list = tag_strings
    end

    def tag_strings
      regex = /(?:^|\s)#(#{VALID_TAG_BODY})/
      matches = self.send(self.class.field_with_tags).scan(regex).map do |match|
        match.last
      end
      unique_matches = matches.inject(Hash.new) do |h,element|
        h[element.downcase] = element unless h[element.downcase]
        h
      end
      unique_matches.values
    end

    def format_tags(text, opts={})
      return text if opts[:plain_text]
      regex = /(^|\s)#(#{VALID_TAG_BODY})/
      form_message = text.gsub(regex) do |matched_string|
        "#{$~[1]}<a href=\"/tags/#{$~[2]}\" class=\"tag\">##{$~[2]}</a>"
      end
      form_message.html_safe
    end
  end
end
