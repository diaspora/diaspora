#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Adapters
  module HCard
    def self.parse(doc)
      DiasporaFederation::WebFinger::HCard.from_html(doc)
    end

    def self.build(raw_hcard)
      parse(raw_hcard)
    end
  end
end
