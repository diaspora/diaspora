module Twitter
  class Base
    extend Forwardable

    def_delegators :client, :get, :post, :put, :delete

    attr_reader :client

    def initialize(client)
      @client = client
    end

    # Options: since_id, max_id, count, page
    def home_timeline(query={})
      perform_get("/#{Twitter.api_version}/statuses/home_timeline.json", :query => query)
    end

    # Options: since_id, max_id, count, page, since
    def friends_timeline(query={})
      perform_get("/#{Twitter.api_version}/statuses/friends_timeline.json", :query => query)
    end

    # Options: id, user_id, screen_name, since_id, max_id, page, since, count
    def user_timeline(query={})
      perform_get("/#{Twitter.api_version}/statuses/user_timeline.json", :query => query)
    end

    def status(id)
      perform_get("/#{Twitter.api_version}/statuses/show/#{id}.json")
    end

    # Options: count
    def retweets(id, query={})
      perform_get("/#{Twitter.api_version}/statuses/retweets/#{id}.json", :query => query)
    end

    # Options: in_reply_to_status_id
    def update(status, query={})
      perform_post("/#{Twitter.api_version}/statuses/update.json", :body => {:status => status}.merge(query))
    end

    # DEPRECATED: Use #mentions instead
    #
    # Options: since_id, max_id, since, page
    def replies(query={})
      warn("DEPRECATED: #replies is deprecated by Twitter; use #mentions instead")
      perform_get("/#{Twitter.api_version}/statuses/replies.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def mentions(query={})
      perform_get("/#{Twitter.api_version}/statuses/mentions.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweeted_by_me(query={})
      perform_get("/#{Twitter.api_version}/statuses/retweeted_by_me.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweeted_to_me(query={})
      perform_get("/#{Twitter.api_version}/statuses/retweeted_to_me.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweets_of_me(query={})
      perform_get("/#{Twitter.api_version}/statuses/retweets_of_me.json", :query => query)
    end

    # options: count, page, ids_only
    def retweeters_of(id, options={})
      ids_only = !!(options.delete(:ids_only))
      perform_get("/#{Twitter.api_version}/statuses/#{id}/retweeted_by#{"/ids" if ids_only}.json", :query => options)
    end

    def status_destroy(id)
      perform_post("/#{Twitter.api_version}/statuses/destroy/#{id}.json")
    end

    def retweet(id)
      perform_post("/#{Twitter.api_version}/statuses/retweet/#{id}.json")
    end

    # Options: id, user_id, screen_name, page
    def friends(query={})
      perform_get("/#{Twitter.api_version}/statuses/friends.json", :query => query)
    end

    # Options: id, user_id, screen_name, page
    def followers(query={})
      perform_get("/#{Twitter.api_version}/statuses/followers.json", :query => query)
    end

    def user(id_or_screen_name, query={})
      if id_or_screen_name.is_a?(Integer)
        query.merge!({:user_id => id_or_screen_name})
      elsif id_or_screen_name.is_a?(String)
        query.merge!({:screen_name => id_or_screen_name})
      end
      perform_get("/#{Twitter.api_version}/users/show.json", :query => query)
    end

    def users(*ids_or_screen_names)
      ids, screen_names = [], []
      ids_or_screen_names.flatten.each do |id_or_screen_name|
        if id_or_screen_name.is_a?(Integer)
          ids << id_or_screen_name
        elsif id_or_screen_name.is_a?(String)
          screen_names << id_or_screen_name
        end
      end
      query = {}
      query[:user_id] = ids.join(",") unless ids.empty?
      query[:screen_name] = screen_names.join(",") unless screen_names.empty?
      perform_get("/#{Twitter.api_version}/users/lookup.json", :query => query)
    end

    # Options: page, per_page
    def user_search(q, query={})
      q = URI.escape(q)
      perform_get("/#{Twitter.api_version}/users/search.json", :query => ({:q => q}.merge(query)))
    end

    # Options: since, since_id, page
    def direct_messages(query={})
      perform_get("/#{Twitter.api_version}/direct_messages.json", :query => query)
    end

    # Options: since, since_id, page
    def direct_messages_sent(query={})
      perform_get("/#{Twitter.api_version}/direct_messages/sent.json", :query => query)
    end

    def direct_message_create(user_id_or_screen_name, text)
      perform_post("/#{Twitter.api_version}/direct_messages/new.json", :body => {:user => user_id_or_screen_name, :text => text})
    end

    def direct_message_destroy(id)
      perform_post("/#{Twitter.api_version}/direct_messages/destroy/#{id}.json")
    end

    def friendship_create(id, follow=false)
      body = {}
      body.merge!(:follow => follow) if follow
      perform_post("/#{Twitter.api_version}/friendships/create/#{id}.json", :body => body)
    end

    def friendship_destroy(id)
      perform_post("/#{Twitter.api_version}/friendships/destroy/#{id}.json")
    end

    def friendship_exists?(a, b)
      perform_get("/#{Twitter.api_version}/friendships/exists.json", :query => {:user_a => a, :user_b => b})
    end

    def friendship_show(query)
      perform_get("/#{Twitter.api_version}/friendships/show.json", :query => query)
    end

    # Options: id, user_id, screen_name
    def friend_ids(query={})
      perform_get("/#{Twitter.api_version}/friends/ids.json", :query => query)
    end

    # Options: id, user_id, screen_name
    def follower_ids(query={})
      perform_get("/#{Twitter.api_version}/followers/ids.json", :query => query)
    end

    def verify_credentials
      perform_get("/#{Twitter.api_version}/account/verify_credentials.json")
    end

    # Device must be sms, im or none
    def update_delivery_device(device)
      perform_post("/#{Twitter.api_version}/account/update_delivery_device.json", :body => {:device => device})
    end

    # One or more of the following must be present:
    #   profile_background_color, profile_text_color, profile_link_color,
    #   profile_sidebar_fill_color, profile_sidebar_border_color
    def update_profile_colors(colors={})
      perform_post("/#{Twitter.api_version}/account/update_profile_colors.json", :body => colors)
    end

    # file should respond to #read and #path
    def update_profile_image(file)
      perform_post("/#{Twitter.api_version}/account/update_profile_image.json", build_multipart_bodies(:image => file))
    end

    # file should respond to #read and #path
    def update_profile_background(file, tile = false)
      perform_post("/#{Twitter.api_version}/account/update_profile_background_image.json", build_multipart_bodies(:image => file).merge(:tile => tile))
    end

    def rate_limit_status
      perform_get("/#{Twitter.api_version}/account/rate_limit_status.json")
    end

    # One or more of the following must be present:
    #   name, email, url, location, description
    def update_profile(body={})
      perform_post("/#{Twitter.api_version}/account/update_profile.json", :body => body)
    end

    # Options: id, page
    def favorites(query={})
      perform_get("/#{Twitter.api_version}/favorites.json", :query => query)
    end

    def favorite_create(id)
      perform_post("/#{Twitter.api_version}/favorites/create/#{id}.json")
    end

    def favorite_destroy(id)
      perform_post("/#{Twitter.api_version}/favorites/destroy/#{id}.json")
    end

    def enable_notifications(id)
      perform_post("/#{Twitter.api_version}/notifications/follow/#{id}.json")
    end

    def disable_notifications(id)
      perform_post("/#{Twitter.api_version}/notifications/leave/#{id}.json")
    end

    def block(id)
      perform_post("/#{Twitter.api_version}/blocks/create/#{id}.json")
    end

    def unblock(id)
      perform_post("/#{Twitter.api_version}/blocks/destroy/#{id}.json")
    end

    # When reporting a user for spam, specify one or more of id, screen_name, or user_id
    def report_spam(options)
      perform_post("/#{Twitter.api_version}/report_spam.json", :body => options)
    end

    def help
      perform_get("/#{Twitter.api_version}/help/test.json")
    end

    def list_create(list_owner_screen_name, options)
      perform_post("/#{Twitter.api_version}/#{list_owner_screen_name}/lists.json", :body => {:user => list_owner_screen_name}.merge(options))
    end

    def list_update(list_owner_screen_name, slug, options)
      perform_put("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/#{slug}.json", :body => options)
    end

    def list_delete(list_owner_screen_name, slug)
      perform_delete("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/#{slug}.json")
    end

    def lists(list_owner_screen_name = nil, query = {})
      path = case list_owner_screen_name
      when nil, Hash
        query = list_owner_screen_name
        "/#{Twitter.api_version}/lists.json"
      else
        "/#{Twitter.api_version}/#{list_owner_screen_name}/lists.json"
      end
      perform_get(path, :query => query)
    end

    def list(list_owner_screen_name, slug)
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/#{slug}.json")
    end

    # :per_page = max number of statues to get at once
    # :page = which page of tweets you wish to get
    def list_timeline(list_owner_screen_name, slug, query = {})
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/#{slug}/statuses.json", :query => query)
    end

    def memberships(list_owner_screen_name, query={})
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/memberships.json", :query => query)
    end

    def subscriptions(list_owner_screen_name, query = {})
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/lists/subscriptions.json", :query => query)
    end

    def list_members(list_owner_screen_name, slug, query = {})
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/members.json", :query => query)
    end

    def list_add_member(list_owner_screen_name, slug, new_id)
      perform_post("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/members.json", :body => {:id => new_id})
    end

    def list_remove_member(list_owner_screen_name, slug, id)
      perform_delete("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/members.json", :query => {:id => id})
    end

    def is_list_member?(list_owner_screen_name, slug, id)
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/members/#{id}.json").error.nil?
    end

    def list_subscribers(list_owner_screen_name, slug, query={})
      perform_get("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/subscribers.json", :body => {:query => query})
    end

    def list_subscribe(list_owner_screen_name, slug)
      perform_post("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/subscribers.json")
    end

    def list_unsubscribe(list_owner_screen_name, slug)
      perform_delete("/#{Twitter.api_version}/#{list_owner_screen_name}/#{slug}/subscribers.json")
    end

    def blocked_ids
      perform_get("/#{Twitter.api_version}/blocks/blocking/ids.json", :mash => false)
    end

    def blocking(options={})
      perform_get("/#{Twitter.api_version}/blocks/blocking.json", options)
    end

    def saved_searches
      perform_get("/#{Twitter.api_version}/saved_searches.json")
    end

    def saved_search(id)
      perform_get("/#{Twitter.api_version}/saved_searches/show/#{id}.json")
    end

    def saved_search_create(query)
      perform_post("/#{Twitter.api_version}/saved_searches/create.json", :body => {:query => query})
    end

    def saved_search_destroy(id)
      perform_delete("/#{Twitter.api_version}/saved_searches/destroy/#{id}.json")
    end

    protected

    def self.mime_type(file)
      case
        when file =~ /\.jpg/ then 'image/jpg'
        when file =~ /\.gif$/ then 'image/gif'
        when file =~ /\.png$/ then 'image/png'
        else 'application/octet-stream'
      end
    end

    def mime_type(f) self.class.mime_type(f) end

    CRLF = "\r\n"

    def self.build_multipart_bodies(parts)
      boundary = Time.now.to_i.to_s(16)
      body = ""
      parts.each do |key, value|
        esc_key = CGI.escape(key.to_s)
        body << "--#{boundary}#{CRLF}"
        if value.respond_to?(:read)
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
          body << "Content-Type: #{mime_type(value.path)}#{CRLF*2}"
          body << value.read
        else
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
        end
        body << CRLF
      end
      body << "--#{boundary}--#{CRLF*2}"
      {
        :body => body,
        :headers => {"Content-Type" => "multipart/form-data; boundary=#{boundary}"}
      }
    end

    def build_multipart_bodies(parts) self.class.build_multipart_bodies(parts) end

    private

    def perform_get(path, options={})
      Twitter::Request.get(self, path, options)
    end

    def perform_post(path, options={})
      Twitter::Request.post(self, path, options)
    end

    def perform_put(path, options={})
      Twitter::Request.put(self, path, options)
    end

    def perform_delete(path, options={})
      Twitter::Request.delete(self, path, options)
    end

  end
end
