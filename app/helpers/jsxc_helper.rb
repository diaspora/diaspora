# frozen_string_literal: true

module JsxcHelper
  def get_bosh_endpoint
    proto = AppConfig.chat.server.bosh.proto
    port = AppConfig.chat.server.bosh.port
    bind = AppConfig.chat.server.bosh.bind
    host = AppConfig.pod_uri.host

    unless AppConfig.chat.server.bosh.proxy?
      return "#{proto}://#{host}:#{port}#{bind}"
    end
    AppConfig.url_to bind
  end
end
