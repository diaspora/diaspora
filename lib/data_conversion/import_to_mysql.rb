# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class ImportToMysql < DataConversion::Base
    def import_raw
      Mongo::User.connection.execute <<-SQL
        LOAD DATA INFILE '#{full_path}/users.csv' INTO TABLE mongo_users
          FIELDS TERMINATED BY ','
          ENCLOSED BY '"'
          IGNORE 1 LINES
        (mongo_id, username, serialized_private_key, encrypted_password,
         invites, invitation_token, invitation_sent_at, getting_started,
         disable_mail, language, last_sign_in_ip, @last_sign_in_at_var,
         reset_password_token, password_salt)
         SET last_sign_in_at = FROM_UNIXTIME(LEFT(@last_sign_in_at_var, LENGTH(@last_sign_in_at_var)-3));
      SQL
    end
  end

end
