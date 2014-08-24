class ConversationsController < ApplicationController
  before_action :authenticate_user!

  layout ->(c) { request.format == :mobile ? "application" : "with_header" }
  use_bootstrap_for :index, :show, :new

  respond_to :html, :mobile, :json, :js

  def index
    @conversations = current_user.conversations.paginate(
      :page => params[:page], :per_page => 15)

    @visibilities = current_user.conversation_visibilities.paginate(
      :page => params[:page], :per_page => 15)

    @conversation = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person_id, :conversation_id => params[:conversation_id]}).first

    @unread_counts = {}
    @visibilities.each { |v| @unread_counts[v.conversation_id] = v.unread }

    @first_unread_message_id = @conversation.try(:first_unread_message, current_user).try(:id)

    @authors = {}
    @conversations.each { |c| @authors[c.id] = c.last_author }

    @ordered_participants = {}
    @conversations.each { |c| @ordered_participants[c.id] = (c.messages.map{|m| m.author}.reverse + c.participants).uniq }

    respond_with do |format|
      format.html
      format.json { render :json => @conversations, :status => 200 }
    end
  end

  def create
    # Can't split nil
    if params[:contact_ids]
      person_ids = current_user.contacts.where(id: params[:contact_ids].split(',')).pluck(:person_id)
    end

    opts = params.require(:conversation).permit(:subject)
    opts[:participant_ids] = person_ids
    opts[:message] = { text: params[:conversation][:text] }
    @conversation = current_user.build_conversation(opts)

    @response = {}
    if person_ids.present? && @conversation.save
      Postzord::Dispatcher.build(current_user, @conversation).post
      @response[:success] = true
      @response[:message] = I18n.t('conversations.create.sent')
      @response[:conversation_id] = @conversation.id
    else
      @response[:success] = false
      @response[:message] = I18n.t('conversations.create.fail')
      if person_ids.blank?
        @response[:message] = I18n.t('conversations.create.no_contact')
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def show
    if @conversation = current_user.conversations.where(id: params[:id]).first

      @first_unread_message_id = @conversation.first_unread_message(current_user).try(:id)
      if @visibility = ConversationVisibility.where(:conversation_id => params[:id], :person_id => current_user.person.id).first
        @visibility.unread = 0
        @visibility.save
      end

      respond_to do |format|
        format.html { redirect_to conversations_path(:conversation_id => @conversation.id) }
        format.js
        format.json { render :json => @conversation, :status => 200 }
      end
    else
      redirect_to conversations_path
    end
  end

  def new
    all_contacts_and_ids = Contact.connection.select_rows(
      Contact.connection.unprepared_statement {
        current_user.contacts.where(:sharing => true).joins(:person => :profile).
          select("contacts.id, profiles.first_name, profiles.last_name, people.diaspora_handle").to_sql
      }
    ).map{|r| {:value => r[0], :name => Person.name_from_attrs(r[1], r[2], r[3]).gsub(/(")/, "'")} }

    @contact_ids = ""

    @contacts_json = all_contacts_and_ids.to_json
    if params[:contact_id]
      @contact_ids = current_user.contacts.find(params[:contact_id]).id
    elsif params[:aspect_id]
      @contact_ids = current_user.aspects.find(params[:aspect_id]).contacts.map{|c| c.id}.join(',')
    end
    if session[:mobile_view] == true && request.format.html?
    render :layout => true
    elsif
    render :layout => false
    end
  end
end
