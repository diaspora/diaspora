class User
  include Mongoid::Document

  field :password
  field :name


  validates :password, :presence => true
  validates :name, :presence =>true

end
