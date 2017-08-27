# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Taggable
    def self.included(model)
      model.class_eval do
        cattr_accessor :field_with_tags

        # validate tag's name maximum length [tag's name should be less than or equal to 255 chars]
        validate :tag_name_max_length, on: :create

        # tag's name is limited to 255 charchters according to ActsAsTaggableOn gem, so we check the length of the name for each tag
        def tag_name_max_length
          self.tag_list.each do |tag|
            errors[:tags] << I18n.t('tags.name_too_long', :count => 255, :current_length => tag.length) if tag.length > 255
          end
        end
        protected :tag_name_max_length
      end
      model.instance_eval do
        before_validation :build_tags # build tags before validation fixs the too long tag name issue #5737

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
      MessageRenderer::Processor.normalize(send(self.class.field_with_tags) || "")
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

    def self.format_tags_for_mail(text)
      regex = /(?<=^|\s|>)#([#{ActsAsTaggableOn::Tag.tag_text_regexp}]+|<3)/u
      text.gsub(regex) do |tag|
        opts = {name: ActsAsTaggableOn::Tag.normalize(tag)}
               .merge(Rails.application.config.action_mailer.default_url_options)
        "[#{tag}](#{Rails.application.routes.url_helpers.tag_url(opts)})"
      end
    end
  end
end
