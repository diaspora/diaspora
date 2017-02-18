class ResharesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    reshare = reshare_service.create(params[:root_guid])
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render text: I18n.t("reshares.create.error"), status: 422
  else
    render json: ExtremePostPresenter.new(reshare, current_user), status: 201
  end

  def index
    render json: reshare_service.find_for_post(params[:post_id])
      .includes(author: :profile)
      .as_api_response(:backbone)
  end

  private

  def reshare_service
    @reshare_service ||= ReshareService.new(current_user)
  end
end
