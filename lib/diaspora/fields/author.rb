module Diaspora
  module Fields
    module Author
      def self.included(model)
        model.class_eval do
          belongs_to :author, class_name: "Person"

          delegate :diaspora_handle, to: :author

          validates :author, presence: true
        end
      end

      def diaspora_handle=(nh)
        self.author = Person.find_or_fetch_by_identifier(nh)
      end
    end
  end
end
