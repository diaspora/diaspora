#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Taggable
    def self.included(model)
      model.class_eval do

        cattr_reader :field_with_tags

        def self.extract_tags_from sym
          puts "extract_tags_from"
          pp self
          @field_with_tags = sym
        end
        def self.field_with_tags_setter
          @field_with_tags_setter = "#{@field_with_tags}=".to_sym
        end
      end
    end

    def build_tags
      self.tag_list = tag_strings
    end

    def tag_strings
      regex = /(?:^|\s)#(\w+)/
      puts "tag strings"
      pp self
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
      regex = /(^|\s)#(\w+)/
      form_message = text.gsub(regex) do |matched_string|
        "#{$~[1]}<a href=\"/p?tag=#{$~[2]}\" class=\"tag\">##{ERB::Util.h($~[2])}</a>"
      end
      form_message
    end
  end
end
