# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110301202619) do

  create_table "aspect_memberships", :force => true do |t|
    t.integer  "aspect_id",  :null => false
    t.integer  "contact_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aspect_memberships", ["aspect_id", "contact_id"], :name => "index_aspect_memberships_on_aspect_id_and_contact_id", :unique => true
  add_index "aspect_memberships", ["aspect_id"], :name => "index_aspect_memberships_on_aspect_id"
  add_index "aspect_memberships", ["contact_id"], :name => "index_aspect_memberships_on_contact_id"

  create_table "aspects", :force => true do |t|
    t.string   "name",                                :null => false
    t.integer  "user_id",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
    t.string   "user_mongo_id"
    t.boolean  "contacts_visible", :default => true,  :null => false
    t.boolean  "open",             :default => false
  end

  add_index "aspects", ["mongo_id"], :name => "index_aspects_on_mongo_id"
  add_index "aspects", ["user_id", "contacts_visible"], :name => "index_aspects_on_user_id_and_contacts_visible"
  add_index "aspects", ["user_id"], :name => "index_aspects_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "text",                   :null => false
    t.integer  "post_id",                :null => false
    t.integer  "person_id",              :null => false
    t.string   "guid",                   :null => false
    t.text     "creator_signature"
    t.text     "post_creator_signature"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "comments", ["guid"], :name => "index_comments_on_guid", :unique => true
  add_index "comments", ["mongo_id"], :name => "index_comments_on_mongo_id"
  add_index "comments", ["person_id"], :name => "index_comments_on_person_id"
  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "contacts", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.integer  "person_id",                    :null => false
    t.boolean  "pending",    :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "contacts", ["mongo_id"], :name => "index_contacts_on_mongo_id"
  add_index "contacts", ["person_id", "pending"], :name => "index_contacts_on_person_id_and_pending"
  add_index "contacts", ["user_id", "pending"], :name => "index_contacts_on_user_id_and_pending"
  add_index "contacts", ["user_id", "person_id"], :name => "index_contacts_on_user_id_and_person_id", :unique => true

  create_table "invitations", :force => true do |t|
    t.text     "message"
    t.integer  "sender_id",    :null => false
    t.integer  "recipient_id", :null => false
    t.integer  "aspect_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "invitations", ["aspect_id"], :name => "index_invitations_on_aspect_id"
  add_index "invitations", ["mongo_id"], :name => "index_invitations_on_mongo_id"
  add_index "invitations", ["recipient_id"], :name => "index_invitations_on_recipient_id"
  add_index "invitations", ["sender_id"], :name => "index_invitations_on_sender_id"

  create_table "mentions", :force => true do |t|
    t.integer "post_id",   :null => false
    t.integer "person_id", :null => false
  end

  add_index "mentions", ["person_id", "post_id"], :name => "index_mentions_on_person_id_and_post_id", :unique => true
  add_index "mentions", ["person_id"], :name => "index_mentions_on_person_id"
  add_index "mentions", ["post_id"], :name => "index_mentions_on_post_id"

  create_table "mongo_aspect_memberships", :force => true do |t|
    t.string   "aspect_mongo_id"
    t.string   "contact_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_aspect_memberships", ["aspect_mongo_id"], :name => "index_mongo_aspect_memberships_on_aspect_mongo_id"
  add_index "mongo_aspect_memberships", ["contact_mongo_id"], :name => "index_mongo_aspect_memberships_on_contact_mongo_id"

  create_table "mongo_aspects", :force => true do |t|
    t.string   "mongo_id"
    t.string   "name"
    t.string   "user_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_aspects", ["user_mongo_id"], :name => "index_mongo_aspects_on_user_mongo_id"

  create_table "mongo_comments", :force => true do |t|
    t.text     "text"
    t.string   "mongo_id"
    t.string   "post_mongo_id"
    t.string   "person_mongo_id"
    t.string   "guid"
    t.text     "creator_signature"
    t.text     "post_creator_signature"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_comments", ["guid"], :name => "index_mongo_comments_on_guid", :unique => true
  add_index "mongo_comments", ["post_mongo_id"], :name => "index_mongo_comments_on_post_mongo_id"

  create_table "mongo_contacts", :force => true do |t|
    t.string   "mongo_id"
    t.string   "user_mongo_id"
    t.string   "person_mongo_id"
    t.boolean  "pending",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_contacts", ["person_mongo_id", "pending"], :name => "index_mongo_contacts_on_person_mongo_id_and_pending"
  add_index "mongo_contacts", ["user_mongo_id", "pending"], :name => "index_mongo_contacts_on_user_mongo_id_and_pending"

  create_table "mongo_invitations", :force => true do |t|
    t.string   "mongo_id"
    t.text     "message"
    t.string   "sender_mongo_id"
    t.string   "recipient_mongo_id"
    t.string   "aspect_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_invitations", ["sender_mongo_id"], :name => "index_mongo_invitations_on_sender_mongo_id"

  create_table "mongo_notifications", :force => true do |t|
    t.string   "mongo_id"
    t.string   "target_type",        :limit => 127
    t.string   "target_mongo_id",    :limit => 127
    t.string   "recipient_mongo_id"
    t.string   "actor_mongo_id"
    t.string   "action"
    t.boolean  "unread",                            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_notifications", ["target_type", "target_mongo_id"], :name => "index_mongo_notifications_on_target_type_and_target_mongo_id"

  create_table "mongo_people", :force => true do |t|
    t.string   "mongo_id"
    t.string   "guid"
    t.text     "url"
    t.string   "diaspora_handle"
    t.text     "serialized_public_key"
    t.string   "owner_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_people", ["diaspora_handle"], :name => "index_mongo_people_on_diaspora_handle", :unique => true
  add_index "mongo_people", ["guid"], :name => "index_mongo_people_on_guid", :unique => true
  add_index "mongo_people", ["owner_mongo_id"], :name => "index_mongo_people_on_owner_mongo_id", :unique => true

  create_table "mongo_post_visibilities", :force => true do |t|
    t.string   "aspect_mongo_id"
    t.string   "post_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_post_visibilities", ["aspect_mongo_id"], :name => "index_mongo_post_visibilities_on_aspect_mongo_id"
  add_index "mongo_post_visibilities", ["post_mongo_id"], :name => "index_mongo_post_visibilities_on_post_mongo_id"

  create_table "mongo_posts", :force => true do |t|
    t.string   "person_mongo_id"
    t.boolean  "public",                  :default => false
    t.string   "diaspora_handle"
    t.string   "guid"
    t.string   "mongo_id"
    t.boolean  "pending",                 :default => false
    t.string   "type"
    t.text     "message"
    t.string   "status_message_mongo_id"
    t.text     "caption"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "image"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_posts", ["guid"], :name => "index_mongo_posts_on_guid"
  add_index "mongo_posts", ["person_mongo_id"], :name => "index_mongo_posts_on_person_mongo_id"
  add_index "mongo_posts", ["type"], :name => "index_mongo_posts_on_type"

  create_table "mongo_profiles", :force => true do |t|
    t.string   "diaspora_handle"
    t.string   "first_name",       :limit => 127
    t.string   "last_name",        :limit => 127
    t.string   "image_url"
    t.string   "image_url_small"
    t.string   "image_url_medium"
    t.date     "birthday"
    t.string   "gender"
    t.text     "bio"
    t.boolean  "searchable",                      :default => true
    t.string   "person_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_profiles", ["first_name", "last_name", "searchable"], :name => "index_mongo_profiles_on_first_name_and_last_name_and_searchable"
  add_index "mongo_profiles", ["first_name", "searchable"], :name => "index_mongo_profiles_on_first_name_and_searchable"
  add_index "mongo_profiles", ["last_name", "searchable"], :name => "index_mongo_profiles_on_last_name_and_searchable"
  add_index "mongo_profiles", ["person_mongo_id"], :name => "index_mongo_profiles_on_person_mongo_id", :unique => true

  create_table "mongo_requests", :force => true do |t|
    t.string   "mongo_id"
    t.string   "sender_mongo_id",    :limit => 127
    t.string   "recipient_mongo_id", :limit => 127
    t.string   "aspect_mongo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_requests", ["recipient_mongo_id"], :name => "index_mongo_requests_on_recipient_mongo_id"
  add_index "mongo_requests", ["sender_mongo_id", "recipient_mongo_id"], :name => "index_mongo_requests_on_sender_mongo_id_and_recipient_mongo_id", :unique => true
  add_index "mongo_requests", ["sender_mongo_id"], :name => "index_mongo_requests_on_sender_mongo_id"

  create_table "mongo_services", :force => true do |t|
    t.string   "mongo_id"
    t.string   "type"
    t.string   "user_mongo_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mongo_services", ["user_mongo_id"], :name => "index_mongo_services_on_user_mongo_id"

  create_table "mongo_users", :force => true do |t|
    t.string   "username"
    t.text     "serialized_private_key"
    t.integer  "invites"
    t.boolean  "getting_started"
    t.boolean  "disable_mail"
    t.string   "language"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "password_salt",                         :default => "", :null => false
    t.string   "invitation_token",       :limit => 20
    t.datetime "invitation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "mongo_users", ["mongo_id"], :name => "index_mongo_users_on_mongo_id", :unique => true

  create_table "notification_actors", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_actors", ["notification_id", "person_id"], :name => "index_notification_actors_on_notification_id_and_person_id", :unique => true
  add_index "notification_actors", ["notification_id"], :name => "index_notification_actors_on_notification_id"
  add_index "notification_actors", ["person_id"], :name => "index_notification_actors_on_person_id"

  create_table "notifications", :force => true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "recipient_id",                   :null => false
    t.boolean  "unread",       :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "notifications", ["recipient_id"], :name => "index_notifications_on_recipient_id"
  add_index "notifications", ["target_id"], :name => "index_notifications_on_target_id"
  add_index "notifications", ["target_type", "target_id"], :name => "index_notifications_on_target_type_and_target_id"

  create_table "people", :force => true do |t|
    t.string   "guid",                  :null => false
    t.text     "url",                   :null => false
    t.string   "diaspora_handle",       :null => false
    t.text     "serialized_public_key", :null => false
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "people", ["diaspora_handle"], :name => "index_people_on_diaspora_handle", :unique => true
  add_index "people", ["guid"], :name => "index_people_on_guid", :unique => true
  add_index "people", ["mongo_id"], :name => "index_people_on_mongo_id"
  add_index "people", ["owner_id"], :name => "index_people_on_owner_id", :unique => true

  create_table "post_visibilities", :force => true do |t|
    t.integer  "aspect_id",  :null => false
    t.integer  "post_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_visibilities", ["aspect_id", "post_id"], :name => "index_post_visibilities_on_aspect_id_and_post_id", :unique => true
  add_index "post_visibilities", ["aspect_id"], :name => "index_post_visibilities_on_aspect_id"
  add_index "post_visibilities", ["post_id"], :name => "index_post_visibilities_on_post_id"

  create_table "posts", :force => true do |t|
    t.integer  "person_id",                            :null => false
    t.boolean  "public",            :default => false, :null => false
    t.string   "diaspora_handle"
    t.string   "guid",                                 :null => false
    t.boolean  "pending",           :default => false, :null => false
    t.string   "type",                                 :null => false
    t.text     "message"
    t.integer  "status_message_id"
    t.text     "caption"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "image"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "posts", ["guid"], :name => "index_posts_on_guid"
  add_index "posts", ["mongo_id"], :name => "index_posts_on_mongo_id"
  add_index "posts", ["person_id"], :name => "index_posts_on_person_id"
  add_index "posts", ["status_message_id", "pending"], :name => "index_posts_on_status_message_id_and_pending"
  add_index "posts", ["status_message_id"], :name => "index_posts_on_status_message_id"
  add_index "posts", ["type", "pending", "id"], :name => "index_posts_on_type_and_pending_and_id"
  add_index "posts", ["type"], :name => "index_posts_on_type"

  create_table "profiles", :force => true do |t|
    t.string   "diaspora_handle"
    t.string   "first_name",       :limit => 127
    t.string   "last_name",        :limit => 127
    t.string   "image_url"
    t.string   "image_url_small"
    t.string   "image_url_medium"
    t.date     "birthday"
    t.string   "gender"
    t.text     "bio"
    t.boolean  "searchable",                      :default => true, :null => false
    t.integer  "person_id",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "profiles", ["first_name", "last_name", "searchable"], :name => "index_profiles_on_first_name_and_last_name_and_searchable"
  add_index "profiles", ["first_name", "searchable"], :name => "index_profiles_on_first_name_and_searchable"
  add_index "profiles", ["last_name", "searchable"], :name => "index_profiles_on_last_name_and_searchable"
  add_index "profiles", ["mongo_id"], :name => "index_profiles_on_mongo_id"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "requests", :force => true do |t|
    t.integer  "sender_id",    :null => false
    t.integer  "recipient_id", :null => false
    t.integer  "aspect_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "requests", ["mongo_id"], :name => "index_requests_on_mongo_id"
  add_index "requests", ["recipient_id"], :name => "index_requests_on_recipient_id"
  add_index "requests", ["sender_id", "recipient_id"], :name => "index_requests_on_sender_id_and_recipient_id", :unique => true
  add_index "requests", ["sender_id"], :name => "index_requests_on_sender_id"

  create_table "services", :force => true do |t|
    t.string   "type",          :null => false
    t.integer  "user_id",       :null => false
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
    t.string   "user_mongo_id"
  end

  add_index "services", ["mongo_id"], :name => "index_services_on_mongo_id"
  add_index "services", ["user_id"], :name => "index_services_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.text     "serialized_private_key"
    t.integer  "invites",                               :default => 0,     :null => false
    t.boolean  "getting_started",                       :default => true,  :null => false
    t.boolean  "disable_mail",                          :default => false, :null => false
    t.string   "language"
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                         :default => "",    :null => false
    t.string   "invitation_token",       :limit => 20
    t.datetime "invitation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
    t.string   "invitation_service",     :limit => 127
    t.string   "invitation_identifier",  :limit => 127
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["invitation_service", "invitation_identifier"], :name => "index_users_on_invitation_service_and_invitation_identifier", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["mongo_id"], :name => "index_users_on_mongo_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  add_foreign_key "aspect_memberships", "aspects", :name => "aspect_memberships_aspect_id_fk"
  add_foreign_key "aspect_memberships", "contacts", :name => "aspect_memberships_contact_id_fk", :dependent => :delete

  add_foreign_key "comments", "people", :name => "comments_person_id_fk", :dependent => :delete
  add_foreign_key "comments", "posts", :name => "comments_post_id_fk", :dependent => :delete

  add_foreign_key "contacts", "people", :name => "contacts_person_id_fk", :dependent => :delete

  add_foreign_key "invitations", "users", :name => "invitations_recipient_id_fk", :column => "recipient_id", :dependent => :delete
  add_foreign_key "invitations", "users", :name => "invitations_sender_id_fk", :column => "sender_id", :dependent => :delete

  add_foreign_key "notification_actors", "notifications", :name => "notification_actors_notification_id_fk", :dependent => :delete

  add_foreign_key "posts", "people", :name => "posts_person_id_fk", :dependent => :delete

  add_foreign_key "profiles", "people", :name => "profiles_person_id_fk", :dependent => :delete

  add_foreign_key "requests", "people", :name => "requests_recipient_id_fk", :column => "recipient_id", :dependent => :delete
  add_foreign_key "requests", "people", :name => "requests_sender_id_fk", :column => "sender_id", :dependent => :delete

  add_foreign_key "services", "users", :name => "services_user_id_fk", :dependent => :delete

end
