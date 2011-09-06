class AddAlgorithmFieldsToRelayableObjects < ActiveRecord::Migration
  def self.up
    add_column :comments, :author_signature_algo, :string
    add_column :comments, :parent_author_signature_algo, :string

    execute <<SQL
    UPDATE comments
      SET comments.author_signature_algo = "SHA"
    WHERE comments.author_signature IS NOT NULL; 
SQL
    execute <<SQL
    UPDATE comments
       SET comments.parent_author_signature_algo = "SHA"
     WHERE comments.author_signature IS NOT NULL
SQL

    add_column :likes, :author_signature_algo, :string
    add_column :likes, :parent_author_signature_algo, :string

    execute <<SQL
    UPDATE likes
       SET likes.author_signature_algo = "SHA"
     WHERE likes.author_signature IS NOT NULL
SQL
    execute <<SQL
    UPDATE likes
       SET likes.parent_author_signature_algo = "SHA"
     WHERE likes.author_signature IS NOT NULL
SQL

    add_column :messages, :author_signature_algo, :string
    add_column :messages, :parent_author_signature_algo, :string

    execute <<SQL
    UPDATE messages
       SET messages.author_signature_algo = "SHA"
     WHERE messages.author_signature IS NOT NULL
SQL
    execute <<SQL
    UPDATE messages
       SET messages.parent_author_signature_algo = "SHA"
     WHERE messages.author_signature IS NOT NULL
SQL
  end

  def self.down
    remove_column :messages, :parent_author_signature_algo
    remove_column :messages, :author_signature_algo

    remove_column :likes, :parent_author_signature_algo
    remove_column :likes, :author_signature_algo

    remove_column :comments, :parent_author_signature_algo
    remove_column :comments, :author_signature_algo
  end
end
