class Backbone::MessagesController < Backbone::BaseController

  before_filter :authenticate_user!

  def index
    conversation = current_user.conversations.includes(messages: { author: :profile }, participants: :profile).where(id: params[:conversation_id]).first
    raise Diaspora::Backbone::NotFound if conversation.nil?

    respond_with Backbone::MessagePresenter.as_collection(paginate(conversation.messages), :full_hash)
  end

  def create
    # find parent conversation
    conversation = current_user.conversations.where(id: params[:conversation_id]).first
    raise Diaspora::Backbone::NotFound if conversation.nil?

    # param processing
    begin
      opts = params.require(:message).permit(:text)
    rescue
      raise Diaspora::Backbone::BadRequest
    end

    # message creation & dispatch
    message = current_user.build_message(conversation, opts)
    raise Diaspora::Backbone::BadRequest unless message.save
    current_user.dispatch(message)

    respond_with Backbone::MessagePresenter.new(message).full_hash
  end
end
