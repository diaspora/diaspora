# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class AspectMembershipsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def destroy
    aspect = current_user.aspects.joins(:aspect_memberships).where(aspect_memberships: {id: params[:id]}).first
    contact = current_user.contacts.joins(:aspect_memberships).where(aspect_memberships: {id: params[:id]}).first

    raise ActiveRecord::RecordNotFound unless aspect.present? && contact.present?

    raise Diaspora::NotMine unless current_user.mine?(aspect) &&
                                   current_user.mine?(contact)

    membership = contact.aspect_memberships.where(aspect_id: aspect.id).first

    raise ActiveRecord::RecordNotFound unless membership.present?

    # do it!
    success = membership.destroy

    # set the flash message
    respond_to do |format|
      format.json do
        if success
          render json: AspectMembershipPresenter.new(membership).base_hash
        else
          render plain: membership.errors.full_messages, status: 403
        end
      end
    end
  end

  def create
    @person = Person.find(params[:person_id])
    @aspect = current_user.aspects.where(id: params[:aspect_id]).first

    @contact = current_user.share_with(@person, @aspect)

    if @contact.present?
      respond_to do |format|
        format.json do
          render json: AspectMembershipPresenter.new(
            AspectMembership.where(contact_id: @contact.id, aspect_id: @aspect.id).first)
          .base_hash
        end
      end
    else
      respond_to do |format|
        format.json do
          render plain: I18n.t("aspects.add_to_aspect.failure"), status: 409
        end
      end
    end
  end

  rescue_from ActiveRecord::StatementInvalid do
    render plain: I18n.t("aspect_memberships.destroy.invalid_statement"), status: 400
  end

  rescue_from ActiveRecord::RecordNotFound do
    render plain: I18n.t("aspect_memberships.destroy.no_membership"), status: 404
  end

  rescue_from Diaspora::NotMine do
    render plain: I18n.t("aspect_memberships.destroy.forbidden"), status: 403
  end
end
