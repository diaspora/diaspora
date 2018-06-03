# frozen_string_literal: true

class RenameArmenianLocaleKey < ActiveRecord::Migration[5.1]
  def up
    User.where(language: "hy").update_all(language: "hye")
  end

  def down
    User.where(language: "hye").update_all(language: "hy")
  end
end
