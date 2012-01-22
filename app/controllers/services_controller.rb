#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See 
#   the COPYRIGHT file.

class ServicesController < ApplicationController
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
      fetch_photo = current_user.person.profile[:image_url].blank?

      current_user.update_profile(current_user.person.profile.from_omniauth_hash(user))
      Resque.enqueue(Jobs::FetchProfilePhoto, current_user.id, service.id, user["image"]) if fetch_photo

      flash[:notice] = I18n.t 'services.create.success'
    else
      flash[:error] = I18n.t 'services.create.failure'

      if existing_service = Service.where(:type => service.type.to_s, :uid => service.uid).first
        flash[:error] <<  I18n.t('services.create.already_authorized',
                                 :diaspora_id => existing_service.user.person.profile.diaspora_handle,
                                 :service_name => provider.camelize )
      end
    end

    if current_user.getting_started
      redirect_to  getting_started_path
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
    @finder = true
    @service = current_user.services.where(:type => "Services::#{params[:provider].titleize}").first
    @friends = @service ? @service.finder(:remote => params[:remote]).paginate( :page => params[:page], :per_page => 15) : []
  end

  def inviter
    @uid = params[:uid]

    if i_id = params[:invitation_id]
      invite = Invitation.find(i_id)
      invited_user = invite.recipient
    else
      invite = Invitation.create(:service => params[:provider], :identifier => @uid, :sender => current_user, :aspect => current_user.aspects.find(params[:aspect_id]))
      invited_user = invite.attach_recipient!
    end

    #to make sure a friend you just invited from facebook shows up as invited
    service = current_user.services.where(:type => "Services::Facebook").first
    su = ServiceUser.where(:service_id => service.id, :uid => @uid).first
    su.attach_local_models
    su.save

    respond_to do |format|
      format.html{ invite_redirect_url(invite, invited_user, su)}
      format.json{ render :json => invite_redirect_json(invite, invited_user, su) }
    end
  end

  def facebook_message_url(user, facebook_uid)
    subject = t('services.inviter.join_me_on_diaspora')
    message = <<MSG
#{t('services.inviter.click_link_to_accept_invitation')}:
\n
\n
#{accept_invitation_url(user, :invitation_token => user.invitation_token)}
MSG
    "https://www.facebook.com/messages/#{facebook_uid}?msg_prefill=#{message}"
  end

  def invite_redirect_json(invite, user, service_user)
    if invite.email_like_identifer
      {:message => t("invitations.create.sent") + service_user.name }
    else
      {:url => facebook_message_url(user, service_user.uid)}
    end
  end

    def invite_redirect_url(invite, user, service_user)
    if invite.email_like_identifer
      redirect_to(friend_finder_path(:provider => 'facebook'), :notice => "you re-invited #{service_user.name}")
    else
      redirect_to(facebook_message_url(user, service_user.uid))
    end
  end
end
