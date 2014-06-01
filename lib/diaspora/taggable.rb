#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Taggable
    def self.included(model)
      model.class_eval do
        cattr_accessor :field_with_tags
      end
      model.instance_eval do
        before_create :build_tags

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
      (send(self.class.field_with_tags) || "")
        .scan(/(?:^|\s)#([#{ActsAsTaggableOn::Tag.tag_text_regexp}]+|<3)/u)
        .map(&:first)
        .uniq(&:downcase)
    end

    def self.format_tags(text, opts={})
      return text if opts[:plain_text]

      text = ERB::Util.h(text) unless opts[:no_escape]
      regex =/(^|\s|>)#([#{ActsAsTaggableOn::Tag.tag_text_regexp}]+|&lt;3)/u

      text.to_str.gsub(regex) { |matched_string|
        pre, url_bit, clickable = $1, $2, "##{$2}"
        if $2 == '&lt;3'
          # Special case for love, because the world needs more love.
          url_bit = '<3'
        end

        %{#{pre}<a class="tag" href="/tags/#{url_bit}">#{clickable}</a>}
      }.html_safe
    end
  end
end
