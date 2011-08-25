#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Shareable
    def self.included(model)
      model.instance_eval do
        has_many :aspect_visibilities, :as => :shareable
        has_many :aspects, :through => :aspect_visibilities

        has_many :share_visibilities, :as => :shareable
        has_many :contacts, :through => :share_visibilities
      end
    end
  end
end
