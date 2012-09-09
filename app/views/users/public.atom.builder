atom_feed({'xmlns:thr' => 'http://purl.org/syndication/thread/1.0',
 'xmlns:georss' => 'http://www.georss.org/georss',
 'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/',
 'xmlns:media' => 'http://purl.org/syndication/atommedia',
 'xmlns:poco' => 'http://portablecontacts.net/spec/1.0',
 'xmlns:ostatus' => 'http://ostatus.org/schema/1.0',
 'xmlns:statusnet' => 'http://status.net/schema/api/1/',
 :id => "#{@user.public_url}.atom",
 :root_url => "#{@user.public_url}"}) do |feed|

  feed.tag! :generator, 'Diaspora', :uri => "#{AppConfig[:pod_url]}"
  feed.title "#{@user.name}'s Public Feed"
  feed.subtitle "Updates from #{@user.name} on Diaspora"
  feed.logo "#{@user.image_url(:thumb_small)}"
  feed.updated @posts[0].created_at if @posts.length > 0
  feed.tag! :link, :rel => 'avatar', :type => 'image/jpeg', 'media:width' => '100',
	    'media:height' => '100', :href => "#{@user.image_url}"
  feed.tag! :link, :href => "#{AppConfig[:pubsub_server]}", :rel => 'hub'

  feed.author do |author|
    author.name @user.name
    author.uri local_or_remote_person_path(@user.person, :absolute => true)

    author.tag! 'activity:object-type', 'http://activitystrea.ms/schema/1.0/person'
    author.tag! 'poco:preferredUsername', @user.username
    author.tag! 'poco:displayName', @user.name
  end


  @posts.each do |post|
    feed.entry post, :url => "#{@user.url}p/#{post.id}",
      :id => "#{@user.url}p/#{post.id}" do |entry|

      entry.title truncate(post.formatted_message(:plain_text => true), :length => 50)
      entry.content auto_link(post.formatted_message(:plain_text => true)), :type => 'html'
      entry.tag! 'activity:verb', 'http://activitystrea.ms/schema/1.0/post'
      entry.tag! 'activity:object-type', 'http://activitystrea.ms/schema/1.0/note'
    end
  end
end
