#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectVisibility < ActiveRecord::Base

  belongs_to :aspect
  validates :aspect, :presence => true

  belongs_to :shareable, :polymorphic => true
  validates :shareable, :presence => true

end
