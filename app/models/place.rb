class Place < ActiveRecord::Base
  include ROXML
  include Encryptor::Public
  include Diaspora::Guid

  has_one :description, :dependent => :destroy
  delegate :title, :image_url, :to => :description
  accepts_nested_attributes_for :description

  validates_presence_of :description

  before_save :auto_diaspora_handle

  #attr_accessible 

  def initialize(attributes={})
    super
    self.description ||= self.build_description
  end

  def auto_diaspora_handle
    self.diaspora_handle ||= description.title_sanitized
  end

end



