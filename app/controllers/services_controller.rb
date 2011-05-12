#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See #   the COPYRIGHT file.

class ServicesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @services = current_user.services
  end

  def create
    auth = request.env['omniauth.auth']

    toke = auth['credentials']['token']
    secret = auth['credentials']['secret']

    provider = auth['provider']
    user     = auth['user_info']

    service = "Services::#{provider.camelize}".constantize.new(:nickname => user['nickname'],
                                                               :access_token => toke,
                                                               :access_secret => secret,
                                                               :uid => auth['uid'])
    current_user.services << service

    flash[:notice] = I18n.t 'services.create.success'
    if current_user.getting_started
      redirect_to  getting_started_path(:step => 3)
    else
      redirect_to services_url
    end
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

  def finder
    service = current_user.services.where(:type => "Services::#{params[:provider].titleize}").first
    @friends = service ? service.finder(:remote => params[:remote]) : []
    render :layout => false
  end

  def inviter
    if current_user.invites == 0
      flash[:error] = I18n.t 'invitations.create.no_more'
      redirect_to :back
      return
    end

    @uid = params[:uid]

    if i_id = params[:invitation_id]
      invited_user = Invitation.find(i_id).recipient
    else
      invited_user = current_user.invite_user(params[:aspect_id], params[:provider], @uid)
    end

    @subject = t('services.inviter.join_me_on_diaspora')
    @message = <<MSG
#{t('services.inviter.click_link_to_accept_invitation')}:
\n
\n
#{accept_invitation_url(invited_user, :invitation_token => invited_user.invitation_token)}
MSG
    redirect_to "https://www.facebook.com/?compose=1&id=#{@uid}&subject=#{@subject}&message=#{@message}&sk=messages"
  end
end
