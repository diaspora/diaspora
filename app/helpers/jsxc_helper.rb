module JsxcHelper
  def get_bosh_endpoint
    port = AppConfig.chat.server.bosh.port
    bind = AppConfig.chat.server.bosh.bind
    host = AppConfig.pod_uri.host

    unless AppConfig.chat.server.bosh.proxy?
      return "http://#{host}:#{port}#{bind}"
    end
    AppConfig.url_to bind
  end
end
