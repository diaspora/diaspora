class DropOpenGraphCachesWithInvalidUrls < ActiveRecord::Migration[4.2]
  def up
    OpenGraphCache.where(url: 'http://').delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration 
  end
end
