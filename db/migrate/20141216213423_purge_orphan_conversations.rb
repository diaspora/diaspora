class PurgeOrphanConversations < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    Conversation.joins("LEFT JOIN conversation_visibilities ON conversation_visibilities.conversation_id = conversations.id").group('conversations.id').having("COUNT(conversation_visibilities.id) = 0").each do |conversation|
      begin
        conversation.delete
      rescue
        puts "PurgeOrphanConversations: Failed to delete orphan conversation #{conversation.id}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
