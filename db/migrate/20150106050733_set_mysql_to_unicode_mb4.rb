class SetMysqlToUnicodeMb4 < ActiveRecord::Migration
  # Converts the tables and strings columns to utf8mb4, which is the true, full
  # unicode support in MySQl
  UTF8_PAIRS = {}
  tables = ActiveRecord::Base.connection.tables

  tables.each do |table|
    ActiveRecord::Base.connection.columns(table).each do |column|
      # build a hash with all the columns that contain text
      if (column.type == :string) || (column.type == :text)
        UTF8_PAIRS[table] = { :name => column.name, :type => column.sql_type }
      end
    end
  end

  def self.up
    # these will only affect tables on InnoDB, and only on rows with the dynamic
    # format
    execute "SET global innodb_file_format = BARRACUDA;"
    execute "SET global innodb_large_prefix = 1;"
    execute "SET global innodb_file_per_table = 1;"
    change_encoding('utf8mb4', 'ENGINE=InnoDB ROW_FORMAT=DYNAMIC') if AppConfig.mysql?
  end

  def self.down
    # let MySQL pick the default engine
    change_encoding('utf8', '') if AppConfig.mysql?
  end

  def change_encoding(encoding, engine)
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET #{encoding};"

    tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = #{encoding} #{engine};"
    end

    UTF8_PAIRS.each do |table, column|
      name = column[:name]
      type = column[:type]
      execute "ALTER TABLE `#{table}` CHANGE `#{name}` `#{name}` #{type}  CHARACTER SET #{encoding} NULL;"
    end
  end
end
