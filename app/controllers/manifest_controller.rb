# frozen_string_literal: true

class ManifestController < ApplicationController
  def show
    render json: '{
      "short_name": "diaspora*",
      "name": "diaspora*",
      "description": "diaspora* is a free, decentralized and privacy respectful social network",
      "icons": [
        {
          "src": "/icon.png",
          "type": "image/png",
          "sizes": "192x192"
        }
      ],
      "start_url": "/",
      "background_color": "#000000",
      "display": "standalone",
      "theme_color": "#000000"
    }'
  end
end
