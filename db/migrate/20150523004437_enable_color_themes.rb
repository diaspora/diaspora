class EnableColorThemes < ActiveRecord::Migration[4.2]
  def up
    add_column(:users, :color_theme, :string)
  end

  def down
    remove_column(:users, :color_theme)
  end
end
