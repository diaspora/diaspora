class MigrateActivityStreamToStatusMessage < ActiveRecord::Migration
  class Post < ActiveRecord::Base; self.inheritance_column = false; end
  def up
    posts_stream_photos = Post.where(type: 'ActivityStreams::Photo')
    posts_stream_photos.each do |p|
      p.update_attributes({text: "#{p.text} ![](#{p.image_url})", type: "StatusMessage"}, without_protection: true)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted ActivityStreams::Photo"
  end
end
