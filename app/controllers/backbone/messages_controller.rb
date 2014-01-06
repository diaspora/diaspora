class Backbone::MessagesController < Backbone::BaseController

  before_filter :authenticate_user!

  def index
    conversation = current_user.conversations.includes(
      messages: { author: :profile },
      participants: :profile
    ).where(id: params[:conversation_id]).first
    raise Diaspora::Backbone::NotFound if conversation.nil?

    respond_with Backbone::MessagePresenter.as_collection(paginate(conversation.messages), :full_hash)
  end

  def create
    message = create_and_dispatch
    respond_with Backbone::MessagePresenter.new(message).full_hash
  end

  private

  def parent_conversation
    conversation_id = params.require(:conversation_id)
    conversation = current_user.conversations.where(id: conversation_id).first
    raise Diaspora::Backbone::NotFound if conversation.nil?
    conversation

  rescue ActionController::ParameterMissing
    raise Diaspora::Backbone::BadRequest
  end

  def params_for_create
    opts = params.require(:message).permit(:text)
  rescue ActionController::ParameterMissing
    raise Diaspora::Backbone::BadRequest
  end

  def create_and_dispatch
    message = current_user.build_message(parent_conversation, params_for_create)
    raise Diaspora::Backbone::BadRequest unless message.save
    current_user.dispatch(message)
    message
  end
end
