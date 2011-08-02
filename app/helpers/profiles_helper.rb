#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ProfilesHelper

  # Creates a profile field <span> with a checked class if set
  #
  # @param [Profile, Symbol] Profile and field in question
  # @return [String] A span element
  def profile_field_tag(profile, field)
    klass = field_filled_out?(profile, field) ? 'completed' : ''
    klass += " profile_field"
    field = case field
            when :tag_string
              :tags
            when :full_name
              :name
            when :image_url
              :photo
            else
              field
            end
    content_tag(:span, t(".profile_fields.#{field.to_s}"), :class => klass)
  end

  private

  # @param [Profile, Symbol] Profile and field in question
  # @return [Boolean] The field in question is set?
  def field_filled_out?(profile, field)
    profile.send("#{field}".to_sym).present?
  end
end
