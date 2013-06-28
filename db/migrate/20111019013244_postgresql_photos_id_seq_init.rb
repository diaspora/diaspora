class PostgresqlPhotosIdSeqInit < ActiveRecord::Migration
  def self.up
    if AppConfig.postgres?
      execute "SELECT setval('photos_id_seq', COALESCE( ( SELECT MAX(id)+1 FROM photos ), 1 ) )"
    end
  end

  def self.down
    # No reason or need to migrate this down.
  end
end
