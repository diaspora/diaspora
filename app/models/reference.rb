# frozen_string_literal: true

class Reference < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  validates :target_id, uniqueness: {scope: %i[target_type source_id source_type]}
end
