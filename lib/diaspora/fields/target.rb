module Diaspora
  module Fields
    module Target
      def self.included(model)
        model.class_eval do
          belongs_to :target, polymorphic: true

          validates :target_id, uniqueness: {scope: %i(target_type author_id)}
          validates :target, presence: true
        end
      end
    end
  end
end
