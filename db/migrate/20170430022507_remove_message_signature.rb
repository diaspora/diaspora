class RemoveMessageSignature < ActiveRecord::Migration
  def change
    remove_column :messages, :author_signature, :text
  end
end
