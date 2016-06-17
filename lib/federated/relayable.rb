module Federated
  class Relayable < ActiveRecord::Base
    self.abstract_class = true

    include Diaspora::Federated::Base
    include Diaspora::Fields::Guid
    include Diaspora::Fields::Author
    include Diaspora::Fields::Target

    include Diaspora::Relayable

    alias_attribute :parent, :target
  end
end
