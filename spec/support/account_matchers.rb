# frozen_string_literal: true

RSpec::Matchers.define :be_a_discovered_person do
  match do |person|
    !Person.by_account_identifier(person.diaspora_handle).nil?
  end
end

RSpec::Matchers.define :be_a_closed_account do
  match(&:closed_account?)
end

RSpec::Matchers.define :be_a_locked_account do
  match(&:access_locked?)
end

RSpec::Matchers.define :be_a_clear_profile do
  match do |profile|
    attributes = %i[
      diaspora_handle first_name last_name image_url image_url_small image_url_medium birthday gender bio
      location nsfw public_details
    ].map {|attribute| profile[attribute] }

    profile.taggings.empty? && !profile.searchable && attributes.reject(&:nil?).empty?
  end
end

RSpec::Matchers.define :be_a_clear_account do
  match do |user|
    attributes = %i[
      language reset_password_token remember_created_at sign_in_count current_sign_in_at last_sign_in_at
      current_sign_in_ip last_sign_in_ip invited_by_id authentication_token unconfirmed_email confirm_email_token
      auto_follow_back auto_follow_back_aspect_id reset_password_sent_at last_seen color_theme
    ].map {|attribute| user[attribute] }

    user.disable_mail &&
      user.strip_exif &&
      !user.getting_started &&
      !user.show_community_spotlight_in_stream &&
      !user.post_default_public &&
      user.email == "deletedaccount_#{user.id}@example.org" &&
      user.hidden_shareables.empty? &&
      attributes.reject(&:nil?).empty?
  end
end
