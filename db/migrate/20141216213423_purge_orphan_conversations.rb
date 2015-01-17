class PurgeOrphanConversations < ActiveRecord::Migration
  def up
    Conversation.where(id: Conversation.joins("LEFT JOIN conversation_visibilities ON conversation_visibilities.conversation_id = conversations.id")
		                       .group('conversations.id')
				       .having("COUNT(conversation_visibilities.id) = 0")
				       .pluck('conversations.id')
    ).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
