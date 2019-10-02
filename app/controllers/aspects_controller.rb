# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_action :authenticate_user!

  respond_to :html,
             :js,
             :json

  def create
    @aspect = current_user.aspects.build(aspect_params)
    aspecting_person_id = params[:person_id]

    if @aspect.save
      result = {id: @aspect.id, name: @aspect.name}
      if aspecting_person_id.present?
        aspect_membership = connect_person_to_aspect(aspecting_person_id)
        result[:aspect_membership] = AspectMembershipPresenter.new(aspect_membership).base_hash if aspect_membership
      end

      render json: result
    else
      head :unprocessable_entity
    end
  end

  def destroy
    begin
      if current_user.auto_follow_back && aspect.id == current_user.auto_follow_back_aspect.id
        current_user.update(auto_follow_back: false, auto_follow_back_aspect: nil)
        flash[:notice] = I18n.t "aspects.destroy.success_auto_follow_back", name: aspect.name
      else
        flash[:notice] = I18n.t "aspects.destroy.success", name: aspect.name
      end
      aspect.destroy
    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = I18n.t "aspects.destroy.failure", name: aspect.name
    end

    if request.referer.include?("contacts")
      redirect_to contacts_path
    else
      redirect_to aspects_path
    end
  end

  def show
    if aspect
      redirect_to aspects_path("a_ids[]" => aspect.id)
    else
      redirect_to aspects_path
    end
  end

  def update
    if aspect.update!(aspect_params)
      flash[:notice] = I18n.t "aspects.update.success", name: aspect.name
    else
      flash[:error] = I18n.t "aspects.update.failure", name: aspect.name
    end
    render json: {id: aspect.id, name: aspect.name}
  end

  def update_order
    params[:ordered_aspect_ids].each_with_index do |id, i|
      current_user.aspects.find(id).update(order_id: i)
    end
    head :no_content
  end

  def toggle_chat_privilege
    aspect.chat_enabled = !aspect.chat_enabled
    aspect.save
    head :no_content
  end

  private

  def aspect
    @aspect ||= current_user.aspects.where(id: (params[:id] || params[:aspect_id])).first
  end

  def connect_person_to_aspect(aspecting_person_id)
    @person = Person.find(aspecting_person_id)
    if @contact = current_user.contact_for(@person)
      @contact.aspect_memberships.create(aspect: @aspect)
    else
      @contact = current_user.share_with(@person, @aspect)
      @contact.aspect_memberships.first
    end
  end

  def aspect_params
    params.require(:aspect).permit(:name, :chat_enabled, :order_id)
  end
end
