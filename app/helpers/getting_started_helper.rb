#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module GettingStartedHelper
  # @return [Boolean] The user has filled out all profile fields
  def has_completed_profile?
    profile = current_user.person.profile
    [:full_name, :image_url,
     :birthday, :gender,
     :bio, :location,
     :tag_string].map! do |attr|
      return false if profile.send(attr).blank?
     end
    true
  end

  # @return [Boolean] The user has connected at least one service
  def has_connected_services?
    AppConfig[:configured_services].blank? || current_user.services.size > 0
  end

  # @return [Boolean] The user has at least 3 contacts
  def has_few_contacts?
    current_user.contacts.receiving.size > 2
  end

  # @return [Boolean] The user has followed at least 3 tags
  def has_few_followed_tags?
    current_user.followed_tags.size > 2
  end
  
  # @return [Boolean] The user has connected to cubbi.es
  def has_connected_cubbies?
    current_user.authorizations.size > 0
  end

  # @return [Boolean] The user has completed all steps in getting started
  def has_completed_getting_started?
    current_user.getting_started == false
  end

  # @return [String] Welcome text with or without the current_user's first_name
  def welcome_text
    if current_user.person.profile.first_name.present?
      t('users.getting_started.welcome_with_name', :name => current_user.first_name)
    else 
      t('users.getting_started.welcome')
    end
  end
end
