# frozen_string_literal: true

class SignatureOrder < ApplicationRecord
  validates :order, presence: true, uniqueness: true
end
