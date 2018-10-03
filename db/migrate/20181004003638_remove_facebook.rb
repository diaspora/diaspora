# frozen_string_literal: true

class RemoveFacebook < ActiveRecord::Migration[5.1]
  class Service < ApplicationRecord
  end

  def change
    remove_column :posts, :facebook_id, :string

    reversible do |change|
      change.up { Service.where(type: "Services::Facebook").delete_all }
    end
  end
end
