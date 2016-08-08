class SignatureOrder < ActiveRecord::Base
  validates :order, presence: true, uniqueness: true
end
