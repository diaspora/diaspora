#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class OEmbedCacheAssociation < ActiveRecord::Base
  belongs_to :post, :inverse_of => :o_embed_caches
  belongs_to :o_embed_cache, :inverse_of => :posts
end
