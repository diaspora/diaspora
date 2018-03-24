# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectVisibility < ApplicationRecord

  belongs_to :aspect

  belongs_to :shareable, :polymorphic => true

  validates :aspect, uniqueness: {scope: %i(shareable_id shareable_type)}
end
