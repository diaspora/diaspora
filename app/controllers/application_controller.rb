#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ApplicationController < ActionController::Base
  has_mobile_fu
  protect_from_forgery :except => :receive

  before_action :ensure_http_referer_is_set
  before_action :set_locale
  before_action :set_diaspora_header
  before_action :set_grammatical_gender
  before_action :mobile_switch
  before_action :gon_set_current_user
  before_action :gon_set_preloads

  inflection_method :grammatical_gender => :gender

  helper_method :all_aspects,
                :all_contacts_count,
                :my_contacts_count,
                :only_sharing_count,
                :tag_followings,
                :tags,
                :open_publisher

  layout ->(c) { request.format == :mobile ? "application" : "centered_with_header_with_footer" }

  private

  def ensure_http_referer_is_set
    request.env['HTTP_REFERER'] ||= '/'
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    # mobile_fu's is_mobile_device? wasn't working here for some reason...
    # it may have been just because of the test env.
    if request.env['HTTP_USER_AGENT'].match(/mobile/i)
      root_path
    else
      new_user_session_path
    end
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

  def set_diaspora_header
    headers['X-Diaspora-Version'] = AppConfig.version_string

    if AppConfig.git_available?
      headers['X-Git-Update'] = AppConfig.git_update if AppConfig.git_update.present?
      headers['X-Git-Revision'] = AppConfig.git_revision if AppConfig.git_revision.present?
    end
  end

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language
    else
      locale = request.preferred_language_from AVAILABLE_LANGUAGE_CODES
      locale ||= request.compatible_language_from AVAILABLE_LANGUAGE_CODES
      locale ||= DEFAULT_LANGUAGE
      I18n.locale = locale
    end
  end

  def redirect_unless_admin
    unless current_user.admin?
      redirect_to stream_url, :notice => 'you need to be an admin to do that'
      return
    end
  end

  def set_grammatical_gender
    if (user_signed_in? && I18n.inflector.inflected_locale?)
      gender = current_user.gender.to_s.tr('!()[]"\'`*=|/\#.,-:', '').downcase
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

  # use :mobile view for mobile and :html for everything else
  # (except if explicitly specified, e.g. :json, :xml)
  def mobile_switch
    if session[:mobile_view] == true && request.format.html?
      request.format = :mobile
    elsif request.format.tablet?
      # we currently don't have any special tablet views...
      request.format = :html
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || current_user_redirect_path
  end

  def max_time
    params[:max_time] ? Time.at(params[:max_time].to_i) : Time.now + 1
  end

  def current_user_redirect_path
    current_user.getting_started? ? getting_started_path : stream_path
  end

  def gon_set_current_user
    return unless user_signed_in?
    a_ids = session[:a_ids] || []
    user = UserPresenter.new(current_user, a_ids)
    gon.push({:user => user})
  end

  def gon_set_preloads
    return unless gon.preloads.nil?
    gon.preloads = {}
  end

  def self.use_bootstrap_for *routes
    before_filter -> {
      @css_framework = :bootstrap
      gon.bootstrap = true
    }, only: routes.flatten
  end
end
