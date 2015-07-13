class CreateScopesTokensJoinTable < ActiveRecord::Migration
  def change
    create_table :scopes_tokens, id: false do |t|
      t.belongs_to :scope, index: true
      t.belongs_to :o_auth_access_token, index: true
    end
  end
end
