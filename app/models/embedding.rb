#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Embedding < ActiveRecord::Base
  belongs_to :post
  belongs_to :o_embed_cache
end
