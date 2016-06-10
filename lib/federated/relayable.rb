module Federated
  class Relayable < ActiveRecord::Base
    self.abstract_class = true

    include Diaspora::Federated::Base
    include Diaspora::Guid

    include Diaspora::Relayable

    belongs_to :target, :polymorphic => true
    belongs_to :author, :class_name => 'Person'
    #end crazy ordering issues

    validates_uniqueness_of :target_id, :scope => [:target_type, :author_id]
    validates :parent, :presence => true #should be in relayable (pending on fixing Message)

    def diaspora_handle
      self.author.diaspora_handle
    end

    def diaspora_handle=(nh)
      self.author = Person.find_or_fetch_by_identifier(nh)
    end

    def parent_class
      self.target_type.constantize
    end

    def parent
      self.target
    end

    def parent= parent
      self.target = parent
    end
  end
end
