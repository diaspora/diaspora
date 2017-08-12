class SignatureOrder < ApplicationRecord
  validates :order, presence: true, uniqueness: true
end
