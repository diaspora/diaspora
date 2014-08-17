class CreatePreferedlanguagesUsersJoin < ActiveRecord::Migration
  def up
    create_table 'preferedlanguages_users', :id => false do |t|
      t.belongs_to :user
      t.belongs_to :preferedlanguage
    end
  end

  def down
    drop_table 'preferedlanguages_users'
  end
end
