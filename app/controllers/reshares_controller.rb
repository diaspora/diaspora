class ResharesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js

  def create
    @reshare = current_user.build_post(:reshare, :root_id => params[:root_id])
    if @reshare.save!
      current_user.add_to_streams(@reshare, current_user.aspects) 
    end

    respond_with @reshare
  end
end
