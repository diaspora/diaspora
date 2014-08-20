class CreatePreferedlanguagesUsersJoin < ActiveRecord::Migration
  def up
    create_table 'preferedlanguages_users', :id => false do |t|
      t.column 'preferedlanguage_id', :integer
      t.column 'user_id', :integer
    end
  end

  def down
    drop_table 'preferedlanguages_users'
  end
end
