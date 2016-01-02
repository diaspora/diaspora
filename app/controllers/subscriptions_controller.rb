class SubscriptionsController < ApplicationController
  def index
    @subscriptions = current_user.subscriptions
  end

  def create
    @subscription = current_user.subscriptions.create(
      channel_type: params[:channel_type], channel_id: params[:channel_id])
    redirect_to :back
  end

  def destroy
    @subscription = Subscription.find params[:id]
    @subscription.destroy
    redirect_to :back
  end
end
