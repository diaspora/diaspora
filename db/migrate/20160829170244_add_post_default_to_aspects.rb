# frozen_string_literal: true

class AddPostDefaultToAspects < ActiveRecord::Migration[4.2]
  def change
    add_column :aspects, :post_default, :boolean, default: true
    add_column :users, :post_default_public, :boolean, default: false
  end
end
