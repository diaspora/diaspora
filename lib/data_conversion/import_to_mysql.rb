# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class ImportToMysql < DataConversion::Base

    def boolean_set(string)
      "#{string}= IF(STRCMP(@#{string},'false'), TRUE, FALSE)"

    end
    def import_raw
      truncate_tables
      import_raw_users
      import_raw_aspects
      import_raw_aspect_memberships
      import_raw_comments
      import_raw_contacts
      import_raw_post_visibilities
      import_raw_requests
    end

    def process_raw_tables

    end

    def truncate_tables
      Mongo::User.connection.execute "TRUNCATE TABLE mongo_users"
      Mongo::Aspect.connection.execute "TRUNCATE TABLE mongo_aspects"
      Mongo::AspectMembership.connection.execute "TRUNCATE TABLE mongo_aspect_memberships"
      Mongo::Comment.connection.execute "TRUNCATE TABLE mongo_comments"
      Mongo::Contact.connection.execute "TRUNCATE TABLE mongo_contacts"
      Mongo::PostVisibility.connection.execute "TRUNCATE TABLE mongo_post_visibilities"
      Mongo::Request.connection.execute "TRUNCATE TABLE mongo_requests"
    end

    def import_raw_users
      log "Loading users file..."
      Mongo::User.connection.execute <<-SQL
        #{load_string("users")}
        #{infile_opts}
        (mongo_id, username, serialized_private_key, encrypted_password,
         invites, invitation_token, invitation_sent_at, @getting_started,
         @disable_mail, language, last_sign_in_ip, @last_sign_in_at_var,
         reset_password_token, password_salt)
         SET last_sign_in_at = FROM_UNIXTIME(LEFT(@last_sign_in_at_var, LENGTH(@last_sign_in_at_var)-3)),
         #{boolean_set("getting_started")},
         #{boolean_set("disable_mail")};
      SQL
      log "Finished. Imported #{Mongo::User.count} users."
    end

    def import_raw_aspects
      log "Loading aspects file..."
      Mongo::Aspect.connection.execute <<-SQL
        #{load_string("aspects")}
        #{infile_opts}
        (mongo_id, name, user_mongo_id, @created_at, @updated_at)
      SQL
      log "Finished. Imported #{Mongo::Aspect.count} aspects."
    end

    def import_raw_aspect_memberships
      log "Loading aspect memberships file..."
      Mongo::AspectMembership.connection.execute <<-SQL
        #{load_string("aspect_memberships")}
        #{infile_opts}
        (contact_mongo_id, aspect_mongo_id)
      SQL
      log "Finished. Imported #{Mongo::AspectMembership.count} aspect memberships."
    end

    def import_raw_comments
      log "Loading comments file..."
      Mongo::Comment.connection.execute <<-SQL
        #{load_string("comments")}
        #{infile_opts}
        (mongo_id, post_mongo_id, person_mongo_id, @diaspora_handle, text, youtube_titles)
        SET guid = mongo_id;
      SQL
      log "Finished. Imported #{Mongo::Comment.count} comments."
    end

    def import_raw_contacts
      log "Loading contacts file..."
      Mongo::Contact.connection.execute <<-SQL
        #{load_string("contacts")}
        #{infile_opts}
        (mongo_id, user_mongo_id, person_mongo_id, @pending, created_at, updated_at)
        SET #{boolean_set("pending")};
      SQL
      log "Finished. Imported #{Mongo::Contact.count} contacts."
    end

    def import_raw_post_visibilities
      log "Loading post visibilities file..."
      Mongo::PostVisibility.connection.execute <<-SQL
        #{load_string("post_visibilities")}
        #{infile_opts}
        (aspect_mongo_id, post_mongo_id)
      SQL
      log "Finished. Imported #{Mongo::PostVisibility.count} post visibilities."
    end

    def import_raw_requests
      log "Loading requests file..."
      Mongo::Request.connection.execute <<-SQL
        #{load_string("requests")}
        #{infile_opts}
        (mongo_id, recipient_mongo_id, sender_mongo_id, aspect_mongo_id)
      SQL
      log "Finished. Imported #{Mongo::Request.count} requests."
    end
    def import_raw_invitations
      log "Loading invitations file..."
      Mongo::Invitation.connection.execute <<-SQL
        #{load_string("invitations")}
        #{infile_opts}
        (mongo_id, recipient_mongo_id, sender_mongo_id, aspect_mongo_id, message)
      SQL
      log "Finished. Imported #{Mongo::Invitation.count} invitations."
    end
    def import_raw_notifications
      log "Loading notifications file..."
      Mongo::Notification.connection.execute <<-SQL
        #{load_string("notifications")}
        #{infile_opts}
        (mongo_id,target_mongo_id,target_type,@unread)
        SET #{boolean_set("unread")};
      SQL
      log "Finished. Imported #{Mongo::Notification.count} notifications."
    end
    def import_raw_people
      log "Loading people file..."
      Mongo::Person.connection.execute <<-SQL
        #{load_string("people")}
        #{infile_opts}
        (created_at,updated_at,serialized_public_key,url,mongo_id,@owner_mongo_id_var,diaspora_handle)
        SET guid = mongo_id,
        owner_mongo_id = NULLIF(@owner_mongo_id_var, '');
      SQL
      log "Finished. Imported #{Mongo::Person.count} people."
    end
    def import_raw_profiles
      log "Loading profiles file..."
      Mongo::Profile.connection.execute <<-SQL
        #{load_string("profiles")}
        #{infile_opts}
        (image_url_medium,@searchable,image_url,person_mongo_id,gender,diaspora_handle,birthday,last_name,bio,image_url_small,first_name)
        SET #{boolean_set("searchable")};
      SQL
      #STRCMP returns 0 if the arguments are the same
      log "Finished. Imported #{Mongo::Profile.count} profiles."
    end
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
  end
end
