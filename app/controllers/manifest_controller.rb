# frozen_string_literal: true

class ManifestController < ApplicationController
  def show # rubocop:disable Metrics/MethodLength
    render json: {
      short_name:       AppConfig.settings.pod_name,
      name:             AppConfig.settings.pod_name,
      description:      "diaspora* is a free, decentralized and privacy-respecting social network",
      icons:            [
        {
          src:   helpers.image_path("branding/logos/app-icon.png"),
          type:  "image/png",
          sizes: "192x192"
        },
        {
          src:   helpers.image_path("branding/logos/app-icon-512.png"),
          type:  "image/png",
          sizes: "512x512"
        }
      ],
      start_url:        "/",
      background_color: "#000000",
      display:          "standalone",
      theme_color:      "#000000"
    }
  end
end
