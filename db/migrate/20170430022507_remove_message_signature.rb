# frozen_string_literal: true

class RemoveMessageSignature < ActiveRecord::Migration[4.2]
  def change
    remove_column :messages, :author_signature, :text
  end
end
