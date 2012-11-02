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
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => 'http://api.tumblr.com')
    access = OAuth::AccessToken.new(consumer, self.access_token, self.access_secret)
    
    body = build_tumblr_post(post, url)
    user_info = JSON.parse(access.get("/v2/user/info").body)
    blogs = user_info["response"]["user"]["blogs"].map { |blog| URI.parse(blog['url']) }
    blogs.each do |blog|
      access.post("/v2/blog/#{blog.host}/post", body)
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
end

