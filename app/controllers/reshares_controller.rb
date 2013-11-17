class ResharesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    @reshare = current_user.build_post(:reshare, :root_guid => params[:root_guid])
    if @reshare.save
      current_user.add_to_streams(@reshare, current_user.aspects)
      current_user.dispatch_post(@reshare, :url => post_url(@reshare), :additional_subscribers => @reshare.root_author)
      render :json => ExtremePostPresenter.new(@reshare, current_user), :status => 201
    else
      render :nothing => true, :status => 422
    end
  end
end
