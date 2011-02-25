class PrivateMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html

  def index
    @messages = PrivateMessage.joins(:private_message_visibilities).where(
                              :private_message_visibilities => {:person_id => current_user.person.id}).all
  end

  def create
    person_ids = Contact.where(:id => params[:private_message][:contact_ids]).map! do |contact|
      contact.person_id
    end

    person_ids = person_ids | [current_user.person.id]

    @message = PrivateMessage.new( :author => current_user.person, :participant_ids => person_ids, :message => params[:private_message][:message] )

    if @message.save
      Rails.logger.info("event=create type=private_message chars=#{params[:private_message][:message].length}")
    end

    respond_with @message
  end

  def show
    @message = PrivateMessage.joins(:private_message_visibilities).where(:id => params[:id],
                              :private_message_visibilities => {:person_id => current_user.person.id}).first

    if @message
      respond_with @message
    else
      redirect_to private_messages_path
    end
  end

end
