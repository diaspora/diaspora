# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :mobile, :json, :js

  def index
    @visibilities = ConversationVisibility.includes(:conversation)
                                          .order("conversations.updated_at DESC")
                                          .where(person_id: current_user.person_id)
                                          .paginate(page: params[:page], per_page: 15)

    if params[:conversation_id]
      @conversation = Conversation.joins(:conversation_visibilities)
                                  .where(conversation_visibilities: {
                                           person_id:       current_user.person_id,
                                           conversation_id: params[:conversation_id]
                                         }).first

      if @conversation
        @first_unread_message_id = @conversation.first_unread_message(current_user).try(:id)
        @conversation.set_read(current_user)
      end
    end

    gon.contacts = contacts_data

    respond_with do |format|
      format.html { render "index", locals: {no_contacts: current_user.contacts.mutual.empty?} }
      format.json { render json: @visibilities.map(&:conversation), status: 200 }
    end
  end

  def create
    # Contacts autocomplete does not work the same way on mobile and desktop
    # Mobile returns contact ids array while desktop returns person id
    # This will have to be removed when mobile autocomplete is ported to Typeahead
    recipients_param, column = [%i(contact_ids id), %i(person_ids person_id)].find {|param, _| params[param].present? }
    if recipients_param
      person_ids = current_user.contacts.mutual.where(column => params[recipients_param].split(",")).pluck(:person_id)
    end

    unless person_ids.present?
      render plain: I18n.t("javascripts.conversation.create.no_recipient"), status: 422
      return
    end

    opts = params.require(:conversation).permit(:subject)
    opts[:participant_ids] = person_ids
    opts[:message] = { text: params[:conversation][:text] }
    @conversation = current_user.build_conversation(opts)

    if @conversation.save
      Diaspora::Federation::Dispatcher.defer_dispatch(current_user, @conversation)
      flash[:notice] = I18n.t("conversations.create.sent")
      render json: {id: @conversation.id}
    else
      render plain: I18n.t("conversations.create.fail"), status: 422
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to conversations_path(conversation_id: params[:id])
        return
      end

      if @conversation = current_user.conversations.where(id: params[:id]).first
        @first_unread_message_id = @conversation.first_unread_message(current_user).try(:id)
        @conversation.set_read(current_user)

        format.json { render :json => @conversation, :status => 200 }
      else
        redirect_to conversations_path
      end
    end
  end

  def raw
    @conversation = current_user.conversations.where(id: params[:conversation_id]).first
    if @conversation
      @first_unread_message_id = @conversation.first_unread_message(current_user).try(:id)
      @conversation.set_read(current_user)
      render partial: "conversations/show", locals: {conversation: @conversation}
    else
      head :not_found
    end
  end

  def new
    if !params[:modal] && !session[:mobile_view] && request.format.html?
      redirect_to conversations_path
      return
    end

    if session[:mobile_view] == true && request.format.html?
      @contacts_json = contacts_data.to_json

      @contact_ids = if params[:contact_id]
                       current_user.contacts.find(params[:contact_id]).id
                     elsif params[:aspect_id]
                       current_user.aspects.find(params[:aspect_id]).contacts.pluck(:id).join(",")
                     end

      render :layout => true
    else
      render :layout => false
    end
  end

  private

  def contacts_data
    current_user.contacts.mutual.joins(person: :profile)
      .pluck(*%w(contacts.id profiles.first_name profiles.last_name people.diaspora_handle))
      .map {|contact_id, *name_attrs|
        {value: contact_id, name: ERB::Util.h(Person.name_from_attrs(*name_attrs)) }
      }
  end
end
