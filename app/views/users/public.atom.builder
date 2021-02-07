# frozen_string_literal: true

atom_feed("xmlns:thr"       => "https://purl.org/syndication/thread/1.0",
          "xmlns:georss"    => "https://www.georss.org/georss",
          "xmlns:activity"  => "https://activitystrea.ms/spec/1.0/",
          "xmlns:media"     => "https://purl.org/syndication/atommedia",
          "xmlns:poco"      => "https://portablecontacts.net/spec/1.0",
          "xmlns:ostatus"   => "https://ostatus.org/schema/1.0",
          "xmlns:statusnet" => "https://status.net/schema/api/1/",
          :id               => @user.atom_url,
          :root_url         => @user.profile_url) do |feed|

  feed.tag! :generator, 'Diaspora', :uri => "#{AppConfig.pod_uri.to_s}"
  feed.title "#{@user.name}'s Public Feed"
  feed.subtitle "Updates from #{@user.name} on #{AppConfig.settings.pod_name}"
  feed.logo @user.image_url(size: :thumb_small)
  feed.updated @posts[0].created_at if @posts.length > 0
  feed.tag! :link, :rel => 'avatar', :type => 'image/jpeg', 'media:width' => '100',
	    'media:height' => '100', :href => "#{@user.image_url}"
  feed.tag! :link, :href => "#{AppConfig.environment.pubsub_server}", :rel => 'hub'

  add_activitystreams_author(feed, @user.person)

  @posts.each do |post|
    feed.entry post, :url => "#{@user.url}p/#{post.id}",
      :id => "#{@user.url}p/#{post.id}" do |entry|

      entry.title post_page_title(post)
      entry.content post.message.markdownified(disable_hovercards: true), :type => 'html'
      add_activitystreams_author(entry, post.author)

      entry.tag! 'activity:verb', 'https://activitystrea.ms/schema/1.0/post'
      entry.tag! 'activity:object-type', 'https://activitystrea.ms/schema/1.0/note'
    end
  end
end
