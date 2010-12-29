#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

DatabaseCleaner::ActiveRecord::Truncation.class_eval do
  # You could argue that this technically isn't truncation. You'd be right.
  # But something in the MySQL adapter segfaults (!) on actual truncation, and we
  # don't have that much data in our tests, so a DELETE is not appreciably slower.
  def clean
    connection.disable_referential_integrity do
      tables_to_truncate.each do |table_name|
        connection.execute("DELETE FROM #{table_name};")
      end
    end
  end
end