class EnableColorThemes < ActiveRecord::Migration
  def up
    add_column(:users, :color_theme, :string)
  end

  def down
    remove_column(:users, :color_theme)
  end
end
