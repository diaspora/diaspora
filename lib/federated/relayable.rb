module Federated
  class Relayable < ActiveRecord::Base
    self.abstract_class = true

    include Diaspora::Federated::Base
    include Diaspora::Fields::Guid
    include Diaspora::Fields::Author

    include Diaspora::Relayable

    belongs_to :target, polymorphic: true

    alias_attribute :parent, :target

    validates :target_id, uniqueness: {scope: %i(target_type author_id)}
    validates :target, presence: true # should be in relayable (pending on fixing Message)
  end
end
