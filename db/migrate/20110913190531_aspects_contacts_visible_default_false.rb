class AspectsContactsVisibleDefaultFalse < ActiveRecord::Migration
  def self.up
    change_table :aspects do |t|
      t.change :contacts_visible, :boolean, {:default => false, :null => false}
    end
  end

  def self.down
    change_table :aspects do |t|
      t.change :contacts_visible, :boolean, {:default => true, :null => false}
    end
  end
end
