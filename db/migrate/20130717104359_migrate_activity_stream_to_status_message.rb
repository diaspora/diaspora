class MigrateActivityStreamToStatusMessage < ActiveRecord::Migration
  def up
    posts_stream_photos = Post.where(:type => 'ActivityStreams::Photo')
    posts_stream_photos.each do |p|
      p.update_attributes(:text => "#{p.text} ![](#{p.image_url})", :type => "StatusMessage")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted ActivityStreams::Photo"
  end
end
