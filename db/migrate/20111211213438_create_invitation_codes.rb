class CreateInvitationCodes < ActiveRecord::Migration
  def self.up
    create_table :invitation_codes do |t|
      t.string :token
      t.integer :user_id
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :invitation_codes
  end
end
