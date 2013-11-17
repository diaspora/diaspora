#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See 
#   the COPYRIGHT file.
class ServicesController < ApplicationController
  # We need to take a raw POST from an omniauth provider with no authenticity token.
  # See https://github.com/intridea/omniauth/issues/203
  # See also http://www.communityguides.eu/articles/16
  skip_before_action :verify_authenticity_token, :only => :create
  before_action :authenticate_user!
  before_action :abort_if_already_authorized, :abort_if_read_only_access, :only => :create

  respond_to :html
  respond_to :json, :only => :inviter

  def index
    @services = current_user.services
  end

  def create 
    service = Service.initialize_from_omniauth( omniauth_hash )
    
    if current_user.services << service
      current_user.update_profile_with_omniauth( service.info )

      fetch_photo(service) if no_profile_image?

      flash[:notice] = I18n.t 'services.create.success'
    else
      flash[:error] = I18n.t 'services.create.failure'
    end
    redirect_to_origin
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

  private

  def abort_if_already_authorized
    if service = Service.where(uid: omniauth_hash['uid']).first
      flash[:error] =  I18n.t( 'services.create.already_authorized',
                                  diaspora_id:  service.user.profile.diaspora_handle,
                                  service_name: service.provider.camelize )
      redirect_to_origin
    end
  end

  def abort_if_read_only_access
    if omniauth_hash['provider'] == 'twitter' && twitter_access_level == 'read'
      flash[:error] =  I18n.t( 'services.create.read_only_access' )
      redirect_to_origin
    end
  end

  def redirect_to_origin
    if origin 
      redirect_to origin
    else 
      render(text: "<script>window.close()</script>")
    end
  end

  def no_profile_image?
    current_user.profile[:image_url].blank?
  end

  def fetch_photo(service)
    Workers::FetchProfilePhoto.perform_async(current_user.id, service.id, service.info["image"])
  end

  def origin
    request.env['omniauth.origin']
  end

  def omniauth_hash 
    request.env['omniauth.auth']
  end

  def twitter_access_token
    omniauth_hash['extra']['access_token']
  end

  #https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema #=> normalized hash
  #https://gist.github.com/oliverbarnes/6096959 #=> hash with twitter specific extra
  def twitter_access_level
    twitter_access_token.response.header['x-access-level']
  end
end
