# frozen_string_literal: true

module Services
  class Tumblr < Service
    MAX_CHARACTERS = 1000

    def provider
      "tumblr"
    end

    def post(post, url="") # rubocop:disable Metrics/AbcSize
      return true if post.nil? # return if post is deleted while waiting in queue

      body = build_tumblr_post(post, url)
      user_info = JSON.parse(client.get("/v2/user/info").body)
      blogs = user_info["response"]["user"]["blogs"]
      primaryblog = blogs.find {|blog| blog["primary"] } || blogs[0]

      tumblr_ids = {}

      blogurl = URI.parse(primaryblog["url"])
      tumblr_ids[blogurl.host.to_s] = request_to_external_blog(blogurl, body)

      post.tumblr_ids = tumblr_ids.to_json
      post.save
    end

    def post_opts(post)
      {tumblr_ids: post.tumblr_ids} if post.tumblr_ids.present?
    end

    def delete_from_service(opts)
      logger.debug "event=delete_from_service type=tumblr sender_id=#{user_id} tumblr_ids=#{opts[:tumblr_ids]}"
      tumblr_posts = JSON.parse(opts[:tumblr_ids])
      tumblr_posts.each do |blog_name, post_id|
        delete_from_tumblr(blog_name, post_id)
      end
    end

    def build_tumblr_post(post, url)
      {type: "text", format: "markdown", body: tumblr_template(post, url), tags: tags(post), native_inline_images: true}
    end

    private

    def client
      @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, site: "https://api.tumblr.com")
      @client ||= OAuth::AccessToken.new(@consumer, access_token, access_secret)
    end

    def tumblr_template(post, url)
      photo_html = post.photos.map {|photo| "![photo](#{photo.url(:scaled_full)})\n\n" }.join

      "#{photo_html}#{post.message.html(mentioned_people: [])}\n\n[original post](#{url})"
    end

    def tags(post)
      post.tags.pluck(:name).join(",").to_s
    end

    def delete_from_tumblr(blog_name, service_post_id)
      client.post("/v2/blog/#{blog_name}/post/delete", "id" => service_post_id)
    end

    def request_to_external_blog(blogurl, body)
      resp = client.post("/v2/blog/#{blogurl.host}/post", body)
      JSON.parse(resp.body)["response"]["id"] if resp.code == "201"
    end

    def consumer_key
      AppConfig.services.tumblr.key
    end

    def consumer_secret
      AppConfig.services.tumblr.secret
    end
  end
end
