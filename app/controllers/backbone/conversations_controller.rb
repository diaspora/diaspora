class Backbone::ConversationsController < Backbone::BaseController

  before_filter :authenticate_user!

  def index
    data = paginate(current_user.conversations.includes(participants: :profile))
    respond_with Backbone::ConversationPresenter.as_collection(data, :full_hash)
  end

  def create
    conversation = create_and_dispatch(params_for_create)
    respond_with Backbone::ConversationPresenter.new(conversation).full_hash
  end

  private

  def params_for_create
    contact_ids = params.require(:contact_ids)
    raise Diaspora::Backbone::BadRequest unless contact_ids.is_a?(Array)

    opts = params.require(:conversation).permit(:subject, message: :text)
    opts[:participant_ids] = current_user.contacts.where(id: contact_ids).pluck(:person_id)
    opts

  rescue ActionController::ParameterMissing
    raise Diaspora::Backbone::BadRequest
  end

  def create_and_dispatch(opts)
    conversation = current_user.build_conversation(opts)
    raise Diaspora::Backbone::BadRequest unless conversation.save
    current_user.dispatch(conversation)
    conversation
  end
end
