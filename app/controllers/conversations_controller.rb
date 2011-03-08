class ConversationsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
                              :conversation_visibilities => {:person_id => current_user.person.id}).paginate(
                                                             :page => params[:page], :per_page => 15, :order => 'updated_at DESC')

    @visibilities = ConversationVisibility.where( :person_id => current_user.person.id ).paginate(
                                                             :page => params[:page], :per_page => 15, :order => 'updated_at DESC')

    @unread_counts = {}
    @visibilities.each{|v| @unread_counts[v.conversation_id] = v.unread}

    @authors = {}
    @conversations.each{|c| @authors[c.id] = c.last_author}
    
    @conversation = Conversation.joins(:conversation_visibilities).where(
                              :conversation_visibilities => {:person_id => current_user.person.id, :conversation_id => params[:conversation_id]}).first
  end

  def create
    person_ids = Contact.where(:id => params[:contact_ids].split(',')).map! do |contact|
      contact.person_id
    end

    params[:conversation][:participant_ids] = person_ids | [current_user.person.id]
    params[:conversation][:author] = current_user.person

    if @conversation = Conversation.create(params[:conversation])
      Postzord::Dispatch.new(current_user, @conversation).post

      flash[:notice] = "Message sent"
      if params[:profile]
        redirect_to person_path(params[:profile])
      else
        redirect_to conversations_path(:conversation_id => @conversation.id)
      end
    end
  end

  def show
    @conversation = Conversation.joins(:conversation_visibilities).where(:id => params[:id],
                              :conversation_visibilities => {:person_id => current_user.person.id}).first

    if @visibility = ConversationVisibility.where(:conversation_id => params[:id], :person_id => current_user.person.id).first
      @visibility.unread = 0
      @visibility.save
    end

    if @conversation
      render :layout => false
    else
      redirect_to conversations_path
    end
  end

  def new
    @all_contacts_and_ids = current_user.contacts.map{|c| {:value => c.id, :name => c.person.name}}
    @contact = current_user.contacts.find(params[:contact_id]) if params[:contact_id]
    render :layout => false
  end

end
