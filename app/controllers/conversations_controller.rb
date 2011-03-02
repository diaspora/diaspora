class ConversationsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
                              :conversation_visibilities => {:person_id => current_user.person.id}).all
    @conversation = Conversation.joins(:conversation_visibilities).where(
                              :conversation_visibilities => {:person_id => current_user.person.id, :conversation_id => params[:conversation_id]}).first
  end

  def create
    person_ids = Contact.where(:id => params[:conversation].delete(:contact_ids)).map! do |contact|
      contact.person_id
    end

    params[:conversation][:participant_ids] = person_ids | [current_user.person.id]
    params[:conversation][:author] = current_user.person

    @conversation = Conversation.create(params[:conversation])

    redirect_to conversations_path(:conversation_id => @conversation.id)
  end

  def show
    @conversation = Conversation.joins(:conversation_visibilities).where(:id => params[:id],
                              :conversation_visibilities => {:person_id => current_user.person.id}).first

    if @conversation
      render :layout => false
    else
      redirect_to conversations_path
    end
  end

end
