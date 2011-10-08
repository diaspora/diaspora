#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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

  # list of birthday display options
  def available_birthday_options
    options = [
      [I18n.t('profiles.edit.birthday.full'), :full],
      [I18n.t('profiles.edit.birthday.age'),  :age ],
      [I18n.t('profiles.edit.birthday.none'), :none],
    ]
  end

  # found here: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby/2357790#2357790
  def age(birthday)
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end


  private

  # @param [Profile, Symbol] Profile and field in question
  # @return [Boolean] The field in question is set?
  def field_filled_out?(profile, field)
    if field != :image_url
      profile.send("#{field}".to_sym).present?
    else
      profile.send("#{field}".to_sym) != "/images/user/default.png" 
    end
  end
end
