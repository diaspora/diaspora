class CreateAuthorizationsScopesJoinTable < ActiveRecord::Migration
  def change
    create_table :authorizations_scopes, id: false do |t|
      t.belongs_to :authorization, index: true
      t.belongs_to :scope, index: true
    end
  end
end
