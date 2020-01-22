# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class AspectMembershipsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def destroy
    delete_results = AspectsMembershipService.new(current_user).destroy_by_membership_id(params[:id])
    success = delete_results[:success]
    membership = delete_results[:membership]

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
    aspect_membership = AspectsMembershipService.new(current_user).create(params[:aspect_id], params[:person_id])

    if aspect_membership
      respond_to do |format|
        format.json do
          render json: AspectMembershipPresenter.new(aspect_membership).base_hash
        end
      end
    else
      respond_to do |format|
        format.json do
          render plain: I18n.t("aspects.add_to_aspect.failure"), status: 409
        end
      end
    end
  rescue RuntimeError
    respond_to do |format|
      format.json do
        render plain: I18n.t("aspects.add_to_aspect.failure"), status: :conflict
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
