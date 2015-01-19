class SetMysqlToUnicodeMb4 < ActiveRecord::Migration

  UTF8_PAIRS = {
    'comments': 'text',
    'messages': 'text',
    'poll_answers': 'answer',
    'polls': 'question',
    'posts': 'text',
  }

  def self.up
    if ENV['DB'] == 'mysql'
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

      ActiveRecord::Base.connection.tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
      end

      UTF8_PAIRS.each do |table, col|
        execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8mb4  NULL;"
      end
    end
  end

  def self.down
    if ENV['DB'] == 'mysql'
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

      ActiveRecord::Base.connection.tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
      end

      UTF8_PAIRS.each do |table, col|
        execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8  NULL;"
      end
    end
  end
end
