class SaferMigration < ActiveRecord::Migration
  def up
    Conversation.joins("LEFT JOIN conversation_visibilities ON conversation_visibilities.conversation_id = conversations.id").group('conversations.id').having("COUNT(conversation_visibilities.id) = 0").destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
