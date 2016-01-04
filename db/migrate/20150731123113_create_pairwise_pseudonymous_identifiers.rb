# Inspired by https://github.com/nov/openid_connect_sample/blob/master/db/migrate/20110829024140_create_pairwise_pseudonymous_identifiers.rb

class CreatePairwisePseudonymousIdentifiers < ActiveRecord::Migration
  def change
    create_table :ppid do |t|
      t.belongs_to :o_auth_application, index: true
      t.belongs_to :user, index: true

      t.string :guid, :string, limit: 32
      t.string :identifier
    end
    add_foreign_key :ppid, :o_auth_applications
    add_foreign_key :ppid, :users
  end
end
