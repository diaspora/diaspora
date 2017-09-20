# frozen_string_literal: true

class Reference < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  validates :target_id, uniqueness: {scope: %i[target_type source_id source_type]}

  module Source
    extend ActiveSupport::Concern

    included do
      has_many :references, as: :source, dependent: :destroy
    end
  end

  module Target
    extend ActiveSupport::Concern

    included do
      has_many :referenced_by, as: :target, class_name: "Reference", dependent: :destroy
    end
  end
end
