class Services::Tumblr < Service
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
    blogs = user_info["response"]["user"]["blogs"]
    primaryblog = blogs.find {|blog| blog["primary"] } || blogs[0]
    tumblr_ids = {}

    blogurl = URI.parse(primaryblog["url"])
    resp = client.post("/v2/blog/#{blogurl.host}/post", body)
    if resp.code == "201"
      tumblr_ids[blogurl.host.to_s] = JSON.parse(resp.body)["response"]["id"]
    end

    post.tumblr_ids = tumblr_ids.to_json
    post.save
  end

  def build_tumblr_post(post, url)
    { :type => 'text', :format => "markdown", :body => tumblr_template(post, url)  }
  end

  def tumblr_template(post, url)
    html = ''
    post.photos.each do |photo|
      html << "![photo](#{photo.url(:scaled_full)})\n\n"
    end
    # save all the mentions within a post
    @mentions = []
    post.message.instance_values["options"][:mentioned_people].each do |o|
      @person_url = o.url + "people/" + o.guid
      @mentions << {name: o.name, url: @person_url}
    end
    # removes the hovercard link that gets added by default
    html << post.message.html(mentioned_people: [])
    html << "\n\n[original post](#{url})"
    @mentions.each { |mention|
      html.gsub!("#{mention[:name]}", "[#{mention[:name]}](#{mention[:url]})")
    }
    # the following regular expressions matches the tag with its surrounding html
    # the two capture groups capture the tag with and without #-sign to build the
    # markdown link
    html.gsub!(/<a\s.+?>(#([\w|\d|_-|<3]+\b))<\/a>/, '[\1]' + "(#{AppConfig.pod_uri}tags/" + '\2)')
    html
  end

  def delete_post(post)
    if post.present? && post.tumblr_ids.present?
      logger.debug "event=delete_from_service type=tumblr sender_id=#{user_id} post=#{post.guid}"
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
