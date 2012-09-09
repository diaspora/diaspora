#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See 
#   the COPYRIGHT file.

class ServicesController < ApplicationController
  # We need to take a raw POST from an omniauth provider with no authenticity token.
  # See https://github.com/intridea/omniauth/issues/203
  # See also http://www.communityguides.eu/articles/16
  skip_before_filter :verify_authenticity_token, :only => :create

  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :inviter

  def index
    @services = current_user.services
  end

  def create
    auth = request.env['omniauth.auth']

    toke = auth['credentials']['token']
    secret = auth['credentials']['secret']

    provider = auth['provider']
    user     = auth['info']

    service = "Services::#{provider.camelize}".constantize.new(:nickname => user['nickname'],
                                                               :access_token => toke,
                                                               :access_secret => secret,
                                                               :uid => auth['uid'])
    current_user.services << service

    if service.persisted?
      fetch_photo = current_user.profile[:image_url].blank?

      current_user.update_profile(current_user.profile.from_omniauth_hash(user))
      Resque.enqueue(Jobs::FetchProfilePhoto, current_user.id, service.id, user["image"]) if fetch_photo

      flash[:notice] = I18n.t 'services.create.success'
    else
      flash[:error] = I18n.t 'services.create.failure'

      if existing_service = Service.where(:type => service.type.to_s, :uid => service.uid).first
        flash[:error] <<  I18n.t('services.create.already_authorized',
                                 :diaspora_id => existing_service.user.profile.diaspora_handle,
                                 :service_name => provider.camelize )
      end
    end

    render :text => ("<script>window.close()</script>")
  end

  def failure
    Rails.logger.info  "error in oauth #{params.inspect}"
    flash[:error] = t('services.failure.error')
    redirect_to services_url
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.destroy
    flash[:notice] = I18n.t 'services.destroy.success'
    redirect_to services_url
    end

end
