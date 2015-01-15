class DropOpenGraphCachesWithInvalidUrls < ActiveRecord::Migration
  def up
    OpenGraphCache.where(url: 'http://').delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
