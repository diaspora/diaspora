class ResharesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    post = Post.where(:guid => params[:root_guid]).first
    if post.is_a? Reshare
      @reshare = current_user.build_post(:reshare, :root_guid => post.absolute_root.guid)
    else
      @reshare = current_user.build_post(:reshare, :root_guid => params[:root_guid])
    end

    if @reshare.save
      current_user.dispatch_post(@reshare)
      render :json => ExtremePostPresenter.new(@reshare, current_user), :status => 201
    else
      render text: I18n.t("reshares.create.error"), status: 422
    end
  end

  def index
    @reshares = target.reshares.includes(author: :profile)
    render json: @reshares.as_api_response(:backbone)
  end

  private

  def target
    @target ||= current_user.find_visible_shareable_by_id(Post, params[:post_id]) ||
      raise(ActiveRecord::RecordNotFound.new)
  end
end
