class PrivateMessage < ActiveRecord::Base
  include ROXML
  include Diaspora::Guid

  belongs_to :author, :class_name => 'Person'
  has_many :private_message_visibilities
  has_many :participants, :class_name => 'Person', :through => :private_message_visibilities, :source => :person

  def recipients
    self.participants - [self.author]
  end
end
