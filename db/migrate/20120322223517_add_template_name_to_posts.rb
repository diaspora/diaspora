class AddTemplateNameToPosts < ActiveRecord::Migration
  def change # thanks josh susser
    add_column :posts, :frame_name, :string
  end
end
