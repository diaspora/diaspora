#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ApplicationController < ActionController::Base
  has_mobile_fu
  protect_from_forgery :except => :receive

  before_filter :ensure_http_referer_is_set
  before_filter :set_contacts_notifications_and_status, :except => [:create, :update]
  before_filter :count_requests
  before_filter :set_invites
  before_filter :set_locale
  before_filter :set_git_header
  before_filter :which_action_and_user
  prepend_before_filter :clear_gc_stats
  before_filter :set_grammatical_gender

  inflection_method :grammatical_gender => :gender

  def ensure_http_referer_is_set
    request.env['HTTP_REFERER'] ||= '/aspects'
  end

  def set_contacts_notifications_and_status
    if user_signed_in?
      @aspect = nil
      @object_aspect_ids = []
      @all_aspects = current_user.aspects.includes(:aspect_memberships, :post_visibilities)
      @notification_count = Notification.for(current_user, :unread =>true).count
      @user_id = current_user.id
    end
  end

  def count_requests
    @request_count = Request.where(:recipient_id => current_user.person.id).count if current_user
  end

  def set_invites
    if user_signed_in?
      @invites = current_user.invites
    end
  end

  def set_git_header
    headers['X-Git-Update'] = GIT_UPDATE unless GIT_UPDATE.nil?
    headers['X-Git-Revision'] = GIT_REVISION unless GIT_REVISION.nil?
  end

  def which_action_and_user
    str = "event=request_with_user controller=#{self.class} action=#{self.action_name} "
    if current_user
      str << "uid=#{current_user.id} "
      str << "user_created_at='#{current_user.created_at.to_date.to_s}' user_created_at_unix=#{current_user.created_at.to_i} " if current_user.created_at
      str << "user_non_pending_contact_count=#{current_user.contacts.size} user_contact_count=#{Contact.unscoped.where(:user_id => current_user.id).size} "
    else
      str << 'uid=nil'
    end
    Rails.logger.info str
  end

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language
    else
      I18n.locale = request.compatible_language_from AVAILABLE_LANGUAGE_CODES
    end
  end
  def clear_gc_stats
    GC.clear_stats if GC.respond_to?(:clear_stats)
  end

  def redirect_unless_admin
    admins = AppConfig[:admins]
    unless admins.present? && admins.include?(current_user.username)
      redirect_to root_url
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

  def similar_people contact, opts={}
    opts[:limit] ||= 5
    aspect_ids = contact.aspect_ids
    count = Contact.count(:user_id => current_user.id,
                          :person_id.ne => contact.person.id,
                          :aspect_ids.in => aspect_ids)

    if count > opts[:limit]
      offset = rand(count-opts[:limit])
    else
      offset = 0
    end
  end
end
