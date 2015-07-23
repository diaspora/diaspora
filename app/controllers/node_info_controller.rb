class NodeInfoController < ApplicationController
  respond_to :json

  def jrd
    render json: NodeInfo.jrd(CGI.unescape(node_info_url("123.123").sub("123.123", "%{version}")))
  end

  def document
    if NodeInfo.supported_version?(params[:version])
      document = NodeInfoPresenter.new(params[:version])
      render json: document, content_type: document.content_type
    else
      head :not_found
    end
  end
end
