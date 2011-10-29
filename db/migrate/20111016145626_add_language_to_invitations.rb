class AddLanguageToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :language, :string, :default => "en"
  end

  def self.down
    remove_column :invitations, :language
  end
end
