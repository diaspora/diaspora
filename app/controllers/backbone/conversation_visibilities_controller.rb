class Backbone::ConversationVisibilitiesController < Backbone::BaseController

  before_filter :authenticate_user!

  def destroy
    visibility = current_user.conversation_visibilities.where(id: params[:id]).first
    raise Diaspora::Backbone::NotFound unless visibility.present? && visibility.destroy

    head :ok
  end
end
