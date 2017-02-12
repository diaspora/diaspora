class CreateSignatureTables < ActiveRecord::Migration
  class SignatureOrder < ActiveRecord::Base
  end

  RELAYABLES = %i(comment like poll_participation).freeze

  def self.up
    create_table :signature_orders do |t|
      t.string :order, null: false
    end
    add_index :signature_orders, :order, length: 191, unique: true

    RELAYABLES.each {|relayable_type| create_signature_table(relayable_type) }

    migrate_signatures

    RELAYABLES.each {|relayable_type| remove_column "#{relayable_type}s", :author_signature }
  end

  def self.down
    RELAYABLES.each {|relayable_type| add_column "#{relayable_type}s", :author_signature, :text }

    RELAYABLES.each {|relayable_type| restore_signatures(relayable_type) }

    drop_table :comment_signatures
    drop_table :like_signatures
    drop_table :poll_participation_signatures
    drop_table :signature_orders
  end

  private

  def create_signature_table(relayable_type)
    create_table "#{relayable_type}_signatures", id: false do |t|
      t.integer "#{relayable_type}_id", null: false
      t.text    :author_signature,      null: false
      t.integer :signature_order_id,    null: false
      t.text    :additional_data
    end

    add_index "#{relayable_type}_signatures", "#{relayable_type}_id", unique: true

    add_foreign_key "#{relayable_type}_signatures", :signature_orders,
                    name: "#{relayable_type}_signatures_signature_orders_id_fk"
    add_foreign_key "#{relayable_type}_signatures", "#{relayable_type}s",
                    name: "#{relayable_type}_signatures_#{relayable_type}_id_fk", on_delete: :cascade
  end

  def migrate_signatures
    comment_order_id = SignatureOrder.create!(order: "guid parent_guid text author").id
    comment_parent_join = "INNER JOIN posts AS parent ON relayable.commentable_id = parent.id"
    migrate_signatures_for(:comment, comment_order_id, comment_parent_join)

    like_order_id = SignatureOrder.create!(order: "positive guid parent_type parent_guid author").id
    post_like_join = "INNER JOIN posts AS parent ON relayable.target_id = parent.id AND relayable.target_type = 'Post'"
    comment_like_join = "INNER JOIN comments ON relayable.target_id = comments.id " \
                        "AND relayable.target_type = 'Comment' " \
                        "INNER JOIN posts AS parent ON comments.commentable_id = parent.id"
    migrate_signatures_for(:like, like_order_id, post_like_join)
    migrate_signatures_for(:like, like_order_id, comment_like_join)

    poll_participation_order_id = SignatureOrder.create!(order: "guid parent_guid author poll_answer_guid").id
    poll_participation_parent_join = "INNER JOIN polls ON relayable.poll_id = polls.id " \
                                     "INNER JOIN posts AS parent ON polls.status_message_id = parent.id"
    migrate_signatures_for(:poll_participation, poll_participation_order_id, poll_participation_parent_join)
  end

  def migrate_signatures_for(relayable_type, order_id, parent_join)
    execute "INSERT INTO #{relayable_type}_signatures (#{relayable_type}_id, signature_order_id, author_signature) " \
            "SELECT relayable.id, #{order_id}, relayable.author_signature FROM #{relayable_type}s AS relayable " \
            "INNER JOIN people AS author ON relayable.author_id = author.id " \
            "#{parent_join} INNER JOIN people AS parent_author ON parent.author_id = parent_author.id " \
            "WHERE author.owner_id IS NULL AND parent_author.owner_id IS NOT NULL AND relayable.author_signature IS NOT NULL"
  end

  def restore_signatures(relayable_type)
    if AppConfig.postgres?
      execute "UPDATE #{relayable_type}s SET author_signature = #{relayable_type}_signatures.author_signature " \
              "FROM #{relayable_type}_signatures " \
              "WHERE #{relayable_type}s.id = #{relayable_type}_signatures.#{relayable_type}_id "
    else
      execute "UPDATE #{relayable_type}s INNER JOIN #{relayable_type}_signatures " \
              "ON #{relayable_type}s.id = #{relayable_type}_signatures.#{relayable_type}_id " \
              "SET #{relayable_type}s.author_signature = #{relayable_type}_signatures.author_signature"
    end
  end
end
