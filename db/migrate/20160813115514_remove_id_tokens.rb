require_relative "20150714055110_create_id_tokens"

class RemoveIdTokens < ActiveRecord::Migration
  def change
    revert CreateIdTokens
  end
end
