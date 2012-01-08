class ResharesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    @reshare = current_user.build_post(:reshare, :root_guid => params[:root_guid])
    if @reshare.save
      current_user.add_to_streams(@reshare, current_user.aspects)
      current_user.dispatch_post(@reshare, :url => post_url(@reshare), :additional_subscribers => @reshare.root.author)
    end

    render :json => @reshare.as_api_response(:backbone), :status => 201
  end
end
