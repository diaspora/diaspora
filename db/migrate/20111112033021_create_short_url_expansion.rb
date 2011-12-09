class CreateShortUrlExpansion < ActiveRecord::Migration
  def self.up
    create_table :short_url_expansions do |t|
      t.string :url_short
      t.string :url_expanded, :limit => 1024

      t.timestamps
    end
  end

  def self.down
    drop_table :short_url_expansions
  end
end
