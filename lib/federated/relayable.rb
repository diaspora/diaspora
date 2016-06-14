module Federated
  class Relayable < ActiveRecord::Base
    self.abstract_class = true

    include Diaspora::Federated::Base
    include Diaspora::Guid

    include Diaspora::Relayable

    belongs_to :target, polymorphic: true
    belongs_to :author, class_name: "Person"

    delegate :diaspora_handle, to: :author

    alias_attribute :parent, :target

    validates :target_id, uniqueness: {scope: %i(target_type author_id)}
    validates :target, presence: true # should be in relayable (pending on fixing Message)

    def diaspora_handle=(nh)
      self.author = Person.find_or_fetch_by_identifier(nh)
    end
  end
end
