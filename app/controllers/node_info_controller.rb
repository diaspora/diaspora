# frozen_string_literal: true

class NodeInfoController < ApplicationController
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

  def statistics
    respond_to do |format|
      format.json { head :not_acceptable }
      format.all { @statistics = NodeInfoPresenter.new("1.0") }
    end
  end

  # TODO: this is only a dummy endpoint, because old versions of the ConnectionTester (<= 0.7.17.0)
  #  checked for this endpoint. Remove this endpoint again once most pods are updated to >= 0.7.18.0
  def host_meta
    render xml: <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
      </XRD>
    XML
  end
end
