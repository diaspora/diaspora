class CleanupInvalidOEmbedCaches < ActiveRecord::Migration[5.1]
  class OEmbedCache < ApplicationRecord
  end
  class Post < ApplicationRecord
  end

  def up
    ids = OEmbedCache.where("data LIKE '%!binary%'").ids
    Post.where(o_embed_cache_id: ids).update_all(o_embed_cache_id: nil) # rubocop:disable Rails/SkipsModelValidations
    OEmbedCache.where(id: ids).delete_all
  end
end
