class Services::Tumblr < Service
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper

  MAX_CHARACTERS = 1000

  def provider
    "tumblr"
  end

  def consumer_key
    AppConfig.services.tumblr.key
  end

  def consumer_secret
    AppConfig.services.tumblr.secret
  end

  def post(post, url='')
    body = build_tumblr_post(post, url)
    user_info = JSON.parse(client.get("/v2/user/info").body)
    blogs = user_info["response"]["user"]["blogs"].map { |blog| URI.parse(blog['url']) }
    tumblr_ids = {}
    blogs.each do |blog|
      resp = client.post("/v2/blog/#{blog.host}/post", body)
      if resp.code == "201"
        tumblr_ids[blog.host.to_s] = JSON.parse(resp.body)["response"]["id"]
      end
    post.tumblr_ids = tumblr_ids.to_json
    post.save
    end
  end

  def build_tumblr_post(post, url)
    { :type => 'text', :format => "markdown", :body => tumblr_template(post, url)  }
  end

  def tumblr_template(post, url)
    html = ''
    post.photos.each do |photo|
      html += "![photo](#{photo.url(:scaled_full)})\n\n"
    end
    html += post.text
    html += "\n\n[original post](#{url})"
  end

  def delete_post(post)
    if post.present? && post.tumblr_ids.present?
      Rails.logger.debug("event=delete_from_service type=tumblr sender_id=#{self.user_id}")
      tumblr_posts = JSON.parse(post.tumblr_ids)
      tumblr_posts.each do |blog_name,post_id|
        delete_from_tumblr(blog_name, post_id)
      end
    end
  end

  def delete_from_tumblr(blog_name, service_post_id)
    client.post("/v2/blog/#{blog_name}/post/delete", "id" => service_post_id)
  end

  private
  def client
    @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, :site => 'http://api.tumblr.com')
    @client ||= OAuth::AccessToken.new(@consumer, self.access_token, self.access_secret)
  end
end

