# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class ImportToMysql < DataConversion::Base
    def infile_opts
      <<-OPTS
          FIELDS TERMINATED BY ','
          ENCLOSED BY '"'
          IGNORE 1 LINES
OPTS
    end
    def load_string model_name
        "LOAD DATA INFILE '#{full_path}/#{model_name}.csv' INTO TABLE mongo_#{model_name}"
    end
    def import_raw_users
      Mongo::User.connection.execute <<-SQL
        #{load_string("users")}
        #{infile_opts}
        (mongo_id, username, serialized_private_key, encrypted_password,
         invites, invitation_token, invitation_sent_at, getting_started,
         disable_mail, language, last_sign_in_ip, @last_sign_in_at_var,
         reset_password_token, password_salt)
         SET last_sign_in_at = FROM_UNIXTIME(LEFT(@last_sign_in_at_var, LENGTH(@last_sign_in_at_var)-3));
      SQL
    end
    def import_raw_aspects
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("aspects")}
        #{infile_opts}
        (mongo_id, name, user_mongo_id, @created_at, @updated_at)
      SQL
    end
    def import_raw_aspect_memberships
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("aspect_memberships")}
        #{infile_opts}
        (contact_mongo_id, aspect_mongo_id)
      SQL
    end
    def import_raw_comments
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("comments")}
        #{infile_opts}
        (mongo_id, post_mongo_id, person_mongo_id, @diaspora_handle, text, youtube_titles)
        SET guid = mongo_id;
      SQL
    end
    def import_raw_contacts
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("contacts")}
        #{infile_opts}
        (mongo_id, user_mongo_id, person_mongo_id, pending, created_at, updated_at)
      SQL
    end
    def import_raw_post_visibilities
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("post_visibilities")}
        #{infile_opts}
        (aspect_mongo_id, post_mongo_id)
      SQL
    end
  end

end
