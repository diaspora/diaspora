# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

module DataConversion
  class Base
    attr_accessor :start_time, :directory, :full_path

    def initialize(start_time = Time.now)
      @start_time = start_time
      @directory = "tmp/export-for-mysql"
      @full_path = "#{Rails.root}/#{directory}"
    end
    def models
      @models ||= [
        {:name => :aspects,
         :main_attrs  => ["mongo_id", "name", "user_mongo_id", "created_at", "updated_at"],
         :mongo_attrs => ["_id"     , "name", "user_id"      , "created_at", "updated_at"],
         :join_table_name => :post_visibilities,
         :join_table_attrs => ["aspect_mongo_id", "post_mongo_id"]},
        {:name => :comments,
         :attrs =>        ["mongo_id", "post_mongo_id", "person_mongo_id", "diaspora_handle", "text", "youtube_titles", "created_at", "updated_at"],
         :mongo_attrs =>  ["_id",      "post_id",       "person_id",       "diaspora_handle", "text", "youtube_titles", "created_at", "updated_at"]},
        {:name => :contacts,
         :main_attrs       => ["mongo_id", "user_mongo_id", "person_mongo_id", "pending", "created_at", "updated_at"],
         :main_mongo_attrs => ["_id"     , "user_id"      , "person_id"      , "pending", "created_at", "updated_at"],
         :join_table_name => :aspect_memberships,
         :join_table_attrs => ["contact_mongo_id", "aspect_mongo_id"]},
        {:name => :invitations,
         :attrs       => ["mongo_id", "recipient_mongo_id", "sender_mongo_id", "aspect_mongo_id", "message", "created_at", "updated_at"],
         :mongo_attrs => ["_id"     , "to_id"             , "from_id"        , "into_id"        , "message", "created_at", "updated_at"]},
        {:name => :notifications,
         :attrs       => ["mongo_id", "target_mongo_id", "recipient_mongo_id", "actor_mongo_id", "action", "target_type", "unread", "created_at", "updated_at"],
         :mongo_attrs => ["_id"     , "target_id"      , "user_id"           , "person_id"     , "action", "kind"       , "unread", "created_at", "updated_at"]},
        {:name => :people,
         :attrs => ["created_at", "updated_at", "serialized_public_key", "url", "mongo_id", "owner_mongo_id", "diaspora_handle"],
         :profile_attrs => ["image_url_medium", "searchable", "image_url", "person_mongo_id", "gender", "diaspora_handle", "birthday", "last_name", "bio", "image_url_small", "first_name"]},
        {:name => :posts,
        :attrs       => ["youtube_titles", "pending", "created_at", "public", "updated_at", "status_message_mongo_id", "caption", "remote_photo_path", "remote_photo_name", "random_string", "image"         , "mongo_id", "type", "diaspora_handle", "person_mongo_id", "message"],
        :mongo_attrs => ["youtube_titles", "pending", "created_at", "public", "updated_at", "status_message_id"      , "caption", "remote_photo_path", "remote_photo_name", "random_string", "image_filename", "_id"    , "_type", "diaspora_handle", "person_id"      , "message"]},
        {:name => :requests,
         :attrs       => ["mongo_id", "recipient_mongo_id", "sender_mongo_id", "aspect_mongo_id", "created_at", "updated_at"],
         :mongo_attrs => ["_id"     , "to_id"             , "from_id"        , "into_id"        , "created_at", "updated_at"]},
         {:name => :services,
           :attrs       => ["mongo_id", "type", "user_mongo_id", "provider", "uid", "access_token", "access_secret", "nickname", "created_at", "updated_at"],
           :mongo_attrs => ["_id"     , "_type", "user_id",      "provider", "uid", "access_token", "access_secret", "nickname", "created_at", "updated_at"]},
        {:name => :users,
        :attrs       => ["mongo_id","email", "username", "serialized_private_key", "encrypted_password", "invites", "invitation_token", "invitation_sent_at", "getting_started", "disable_mail", "language", "last_sign_in_ip", "last_sign_in_at", "reset_password_token", "password_salt", "created_at", "updated_at"],
        :mongo_attrs => ["_id"     , "email","username", "serialized_private_key", "encrypted_password", "invites", "invitation_token", "invitation_sent_at", "getting_started", "disable_mail", "language", "last_sign_in_ip", "last_sign_in_at", "reset_password_token", "password_salt", "created_at", "updated_at"]},
      ]
    end
    def log(message)
      if ['development', 'production'].include?(Rails.env)
        puts "#{sprintf("%.2f", Time.now - start_time)}s #{message}"
      end
      Rails.logger.debug(message) if Rails.logger
    end
  end
end
