class Place < ActiveRecord::Base
  include ROXML
  include Encryptor::Public
  include Diaspora::Guid

  has_one :description, :dependent => :destroy
  delegate :title, :image_url, :to => :description
  accepts_nested_attributes_for :description

  validates_presence_of :description

end



