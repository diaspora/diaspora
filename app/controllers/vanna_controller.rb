#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class VannaController < Vanna::Base
  include Devise::Controllers::Helpers
  include AspectGlobalHelper
  include PeopleHelper
  include UsersHelper

  helper :layout
  helper_method :current_user
  helper_method :all_aspects
  helper_method :flash
  config.stylesheets_dir = "public/stylesheets"
  layout "application"
  include ActionController::Flash
  default_url_options[:host] = "localhost"
  include ActionController::MobileFu::InstanceMethods
  helper_method :is_mobile_device?

  protect_from_forgery :except => :receive

  before_filter :authenticate_user!
  before_filter :ensure_http_referer_is_set
  before_filter :set_header_data, :except => [:create, :update]
  before_filter :set_locale
  before_filter :set_git_header if (AppConfig[:git_update] && AppConfig[:git_revision])
  before_filter :which_action_and_user
  before_filter :all_aspects
  before_filter :set_grammatical_gender

  def ensure_http_referer_is_set
    request.env['HTTP_REFERER'] ||= '/aspects'
  end

  def set_header_data
    if user_signed_in?
      if request.format.html? && !params[:only_posts]
        @aspect = nil
        @notification_count = Notification.for(current_user, :unread =>true).count
        @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
      end
      @all_aspects = current_user.aspects
    end
  end

  def ensure_page
    params[:page] = params[:page] ? params[:page].to_i : 1
  end

  def all_aspects
    @all_aspects ||= current_user.aspects
  end

  def set_git_header
    headers['X-Git-Update'] = AppConfig[:git_update]
    headers['X-Git-Revision'] = AppConfig[:git_revision]
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

    WillPaginate::ViewHelpers.pagination_options[:previous_label] = "&laquo; #{I18n.t('previous')}"
    WillPaginate::ViewHelpers.pagination_options[:next_label] = "#{I18n.t('next')} &raquo;"
  end

  def redirect_unless_admin
    unless current_user.admin?
      redirect_to multi_stream_path, :notice => 'you need to be an admin to do that'
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
    stored_location_for(:user) || aspects_path(:a_ids => current_user.aspects.where(:open => true).select(:id).all.map{|a| a.id})
  end
end
