class SetMysqlToUnicodeMb4 < ActiveRecord::Migration

  UTF8_PAIRS = {}
  tables = ActiveRecord::Base.connection.tables

  tables.each do |table|
    ActiveRecord::Base.connection.columns(table).each do |column|
      # build a hash with all the columns that contain text
      UTF8_PAIRS[table] = column.name if (column.type == :string) || (column.type == :text)
    end
  end

  def self.up
    if AppConfig.mysql?
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

      tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
      end

      UTF8_PAIRS.each do |table, col|
        execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8mb4  NULL;"
      end
    end
  end

  def self.down
    if AppConfig.mysql?
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

      tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
      end

      UTF8_PAIRS.each do |table, col|
        execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8  NULL;"
      end
    end
  end
end
