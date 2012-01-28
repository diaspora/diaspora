#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ApplicationController < ActionController::Base
  has_mobile_fu
  protect_from_forgery :except => :receive

  before_filter :ensure_http_referer_is_set
  before_filter :set_locale
  before_filter :set_git_header if (AppConfig[:git_update] && AppConfig[:git_revision])
  before_filter :set_grammatical_gender

  inflection_method :grammatical_gender => :gender

  helper_method :notification_count,
                :unread_message_count,
                :all_aspects,
                :all_contacts_count,
                :my_contacts_count,
                :only_sharing_count,
                :tag_followings,
                :tags,
                :open_publisher

  def ensure_http_referer_is_set
    request.env['HTTP_REFERER'] ||= root_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    # mobile_fu's is_mobile_device? wasn't working here for some reason...
    # it may have been just because of the test env.
    if request.env['HTTP_USER_AGENT'].match(/mobile/i)
      root_path
    else
      logged_out_path
    end
  end

  ##helpers
  def notification_count
    @notification_count ||= Notification.for(current_user, :unread =>true).size
  end

  def unread_message_count
    @unread_message_count ||= ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
  end 

  def all_aspects
    @all_aspects ||= current_user.aspects
  end

  def all_contacts_count
    @all_contacts_count ||= current_user.contacts.count
  end

  def my_contacts_count
    @my_contacts_count ||= current_user.contacts.receiving.count
  end

  def only_sharing_count
    @only_sharing_count ||= current_user.contacts.only_sharing.count
  end

  def tags
    @tags ||= current_user.followed_tags
  end

  def ensure_page
    params[:page] = params[:page] ? params[:page].to_i : 1
  end

  def set_git_header
    headers['X-Git-Update'] = AppConfig[:git_update] if AppConfig[:git_update].present?
    headers['X-Git-Revision'] = AppConfig[:git_revision] if AppConfig[:git_revision].present?
  end

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language
    else
      locale = request.preferred_language_from AVAILABLE_LANGUAGE_CODES
      locale ||= request.compatible_language_from AVAILABLE_LANGUAGE_CODES
      I18n.locale = locale
    end
  end

  def redirect_unless_admin
    unless current_user.admin?
      redirect_to multi_stream_url, :notice => 'you need to be an admin to do that'
      return
    end
  end

  def set_grammatical_gender
    if (user_signed_in? && I18n.inflector.inflected_locale?)
      gender = current_user.profile.gender.to_s.tr('!()[]"\'`*=|/\#.,-:', '').downcase
      unless gender.empty?
        i_langs = I18n.inflector.inflected_locales(:gender)
        i_langs.delete  I18n.locale
        i_langs.unshift I18n.locale
        i_langs.each do |lang|
          token = I18n.inflector.true_token(gender, :gender, lang)
          unless token.nil?
            @grammatical_gender = token
            break
          end
        end
      end
    end
  end

  def grammatical_gender
    @grammatical_gender || nil
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || (current_user.getting_started? ? getting_started_path : multi_stream_path)
  end

  def max_time
    params[:max_time] ? Time.at(params[:max_time].to_i) : Time.now + 1
  end
end
