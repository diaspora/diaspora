class PrivateMessage < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  has_many :private_message_visibilities
  has_many :recipients, :class_name => 'Person', :through => :private_message_visibilities, :source => :person
end
