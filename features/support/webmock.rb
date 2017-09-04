# frozen_string_literal: true

require "webmock/cucumber"
WebMock.disable_net_connect!(allow_localhost: true)

Before do
  stub_request(:head, /.+/).with(
    headers: {
      "Accept"     => "text/html",
      "User-Agent" => "OpenGraphReader/0.6.2 (+https://github.com/jhass/open_graph_reader)"
    }
  ).to_return(status: 200, body: "", headers: {"Content-Type" => "text/plain"})
end
