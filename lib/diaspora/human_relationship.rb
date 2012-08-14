#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This is a trait for models that extend ActiveRecord::Base
# and define a relationship between a user and a person
module Diaspora::HumanRelationship

  def self.included(model)
    model.class_eval do

      belongs_to :user # owner
      belongs_to :person # target

      validates :user_id, :presence => true
      validates :person_id, :presence => true, :uniqueness => {:scope => :user_id}

      validate :not_targeting_yourself

      def not_targeting_yourself
        if self.user.person.id == self.person_id
          errors[:person_id] << "you cannot target yourself for #{self.class}"
        end
      end

    end
  end

end