class AddLanguageNameToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :language_name, :string
  end
end
