# NOTE: this migration will remove a lot of unused rows.  It is highly suggested
# that you run `OPTIMIZE TABLE share_visibilities` after this
# `OPTIMIZE NO_WRITE_TO_BINLOG TABLE share_visibilities;` will run faster but has a greater chance of corrupting data
# and will only work on an unsharded database (which should be the case for everyone right now)
# you probably want to backup your db before you do any of this.


# migration is complete.
#
# caution: you may want to take your pod offline during the OPTIMIZE command.

class RemovePublicShareVisibilities < ActiveRecord::Migration
  def self.up
    %w{Post Photo}.each do |type|

      index = 0

      table_name = type.tableize
      if AppConfig.postgres?
        shareable_size = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table_name}").first['count'].to_i
      else
        shareable_size = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table_name}").first.first
      end

      while index < shareable_size + 100 do
        if AppConfig.postgres?
          sql = <<-SQL
            DELETE
              FROM share_visibilities AS sv
                USING #{table_name} as p
                WHERE sv.shareable_id = p.id
                  AND sv.shareable_type = '#{type}'
                  AND p.public IS TRUE
                  AND p.id < #{index};
          SQL
        else
          sql = <<-SQL
            DELETE sv
              FROM share_visibilities AS sv
              INNER JOIN #{table_name}
              ON sv.shareable_id = #{table_name}.id
              WHERE sv.shareable_type = "#{type}"
                AND #{table_name}.public IS TRUE
                AND #{table_name}.id < #{index};
	        SQL
        end

        puts "deleted public share vis up to #{index} of #{type}"
        ActiveRecord::Base.connection.execute(sql)

        index += 100
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
