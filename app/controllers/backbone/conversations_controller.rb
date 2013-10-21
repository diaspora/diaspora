class Backbone::ConversationsController < Backbone::BaseController

  before_filter :authenticate_user!

  def index
    data = paginate(current_user.conversations.includes(participants: :profile))
    respond_with Backbone::ConversationPresenter.as_collection(data, :full_hash)
  end

  def create
    # parameter handling
    raise Diaspora::Backbone::BadRequest unless params.has_key?(:contact_ids) &&
                                                params[:contact_ids].is_a?(Array)
    begin
      opts = params.require(:conversation).permit(:subject, message: :text)
    rescue
      raise Diaspora::Backbone::BadRequest
    end

    # record creation & dispatch
    conversation = current_user.build_conversation(opts)
    raise Diaspora::Backbone::BadRequest unless conversation.save
    current_user.dispatch(conversation)

    respond_with Backbone::ConversationPresenter.new(conversation).full_hash
  end
end
