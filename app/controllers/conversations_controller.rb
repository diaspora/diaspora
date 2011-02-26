class ConversationsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
                              :conversation_visibilities => {:person_id => current_user.person.id}).all
  end

  def create
    person_ids = Contact.where(:id => params[:conversation][:contact_ids]).map! do |contact|
      contact.person_id
    end

    person_ids = person_ids | [current_user.person.id]

    @conversation = Conversation.new(:subject => params[:conversation][:subject], :participant_ids => person_ids)

    if @conversation.save
      @message = Message.new(:text => params[:message][:text], :author => current_user.person, :conversation_id => @conversation.id )
      unless @message.save
        @conversation.destroy
      end
    end

    respond_with @conversation
  end

  def show
    @conversation = Conversation.joins(:conversation_visibilities).where(:id => params[:id],
                              :conversation_visibilities => {:person_id => current_user.person.id}).first

    if @conversation
      respond_with @conversation
    else
      redirect_to conversations_path
    end
  end

end
