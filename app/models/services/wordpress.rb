# frozen_string_literal: true

module Services
  class Wordpress < Service
    MAX_CHARACTERS = 1000

    attr_accessor :username, :password, :host, :path

    # uid = blog_id

    def provider
      "wordpress"
    end

    def post(post, _url="")
      res = Faraday.new(url: "https://public-api.wordpress.com").post do |req|
        req.url "/rest/v1/sites/#{uid}/posts/new"
        req.body = post_body(post).to_json
        req.headers["Authorization"] = "Bearer #{access_token}"
        req.headers["Content-Type"] = "application/json"
      end

      JSON.parse res.env[:body]
    end

    def post_body(post)
      {
        title:   post.message.title,
        content: post.message.markdownified(disable_hovercards: true)
      }
    end
  end
end
