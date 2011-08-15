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

ActiveRecord::Schema.define(:version => 20110815174723) do

  create_table "aspect_memberships", :force => true do |t|
    t.integer  "aspect_id",  :null => false
    t.integer  "contact_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aspect_memberships", ["aspect_id", "contact_id"], :name => "index_aspect_memberships_on_aspect_id_and_contact_id", :unique => true
  add_index "aspect_memberships", ["aspect_id"], :name => "index_aspect_memberships_on_aspect_id"
  add_index "aspect_memberships", ["contact_id"], :name => "index_aspect_memberships_on_contact_id"

  create_table "aspect_visibilities", :force => true do |t|
    t.integer  "post_id",    :null => false
    t.integer  "aspect_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aspect_visibilities", ["aspect_id"], :name => "index_aspect_visibilities_on_aspect_id"
  add_index "aspect_visibilities", ["post_id", "aspect_id"], :name => "index_aspect_visibilities_on_post_id_and_aspect_id", :unique => true
  add_index "aspect_visibilities", ["post_id"], :name => "index_aspect_visibilities_on_post_id"

  create_table "aspects", :force => true do |t|
    t.string   "name",                               :null => false
    t.integer  "user_id",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "contacts_visible", :default => true, :null => false
    t.integer  "order_id"
  end

  add_index "aspects", ["user_id", "contacts_visible"], :name => "index_aspects_on_user_id_and_contacts_visible"
  add_index "aspects", ["user_id"], :name => "index_aspects_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "text",                                   :null => false
    t.integer  "post_id",                                :null => false
    t.integer  "author_id",                              :null => false
    t.string   "guid",                                   :null => false
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes_count",             :default => 0, :null => false
  end

  add_index "comments", ["author_id"], :name => "index_comments_on_person_id"
  add_index "comments", ["guid"], :name => "index_comments_on_guid", :unique => true
  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "contacts", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "person_id",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sharing",    :default => false, :null => false
    t.boolean  "receiving",  :default => false, :null => false
  end

  add_index "contacts", ["person_id"], :name => "index_contacts_on_person_id"
  add_index "contacts", ["user_id", "person_id"], :name => "index_contacts_on_user_id_and_person_id", :unique => true

  create_table "conversation_visibilities", :force => true do |t|
    t.integer  "conversation_id",                :null => false
    t.integer  "person_id",                      :null => false
    t.integer  "unread",          :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversation_visibilities", ["conversation_id", "person_id"], :name => "index_conversation_visibilities_on_conversation_id_and_person_id", :unique => true
  add_index "conversation_visibilities", ["conversation_id"], :name => "index_conversation_visibilities_on_conversation_id"
  add_index "conversation_visibilities", ["person_id"], :name => "index_conversation_visibilities_on_person_id"

  create_table "conversations", :force => true do |t|
    t.string   "subject"
    t.string   "guid",       :null => false
    t.integer  "author_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["author_id"], :name => "conversations_author_id_fk"

  create_table "ejabberd_last", :primary_key => "username", :force => true do |t|
    t.text "seconds", :null => false
    t.text "state",   :null => false
  end

  create_table "ejabberd_privacy_default_list", :primary_key => "username", :force => true do |t|
    t.string "name", :limit => 250, :null => false
  end

  create_table "ejabberd_privacy_list", :force => true do |t|
    t.string   "username",   :limit => 250, :null => false
    t.string   "name",       :limit => 250, :null => false
    t.datetime "created_at",                :null => false
  end

  add_index "ejabberd_privacy_list", ["id"], :name => "id", :unique => true
  add_index "ejabberd_privacy_list", ["username", "name"], :name => "i_privacy_list_username_name", :unique => true, :length => {"name"=>75, "username"=>75}
  add_index "ejabberd_privacy_list", ["username"], :name => "i_privacy_list_username"

  create_table "ejabberd_privacy_list_data", :id => false, :force => true do |t|
    t.integer "id",                 :limit => 8
    t.string  "t",                  :limit => 1,                                :null => false
    t.text    "value",                                                          :null => false
    t.string  "action",             :limit => 1,                                :null => false
    t.decimal "ord",                             :precision => 10, :scale => 0, :null => false
    t.boolean "match_all",                                                      :null => false
    t.boolean "match_iq",                                                       :null => false
    t.boolean "match_message",                                                  :null => false
    t.boolean "match_presence_in",                                              :null => false
    t.boolean "match_presence_out",                                             :null => false
  end

  create_table "ejabberd_private_storage", :id => false, :force => true do |t|
    t.string   "username",   :limit => 250, :null => false
    t.string   "namespace",  :limit => 250, :null => false
    t.text     "data",                      :null => false
    t.datetime "created_at",                :null => false
  end

  add_index "ejabberd_private_storage", ["username", "namespace"], :name => "i_private_storage_username_namespace", :unique => true, :length => {"namespace"=>75, "username"=>75}
  add_index "ejabberd_private_storage", ["username"], :name => "i_private_storage_username"

  create_table "ejabberd_pubsub_item", :id => false, :force => true do |t|
    t.integer "nodeid",       :limit => 8
    t.text    "itemid"
    t.text    "publisher"
    t.text    "creation"
    t.text    "modification"
    t.text    "payload"
  end

  add_index "ejabberd_pubsub_item", ["itemid"], :name => "i_pubsub_item_itemid", :length => {"itemid"=>36}
  add_index "ejabberd_pubsub_item", ["nodeid", "itemid"], :name => "i_pubsub_item_tuple", :unique => true, :length => {"itemid"=>36, "nodeid"=>nil}

  create_table "ejabberd_pubsub_node", :primary_key => "nodeid", :force => true do |t|
    t.text "host"
    t.text "node"
    t.text "parent"
    t.text "type"
  end

  add_index "ejabberd_pubsub_node", ["host", "node"], :name => "i_pubsub_node_tuple", :unique => true, :length => {"node"=>120, "host"=>20}
  add_index "ejabberd_pubsub_node", ["parent"], :name => "i_pubsub_node_parent", :length => {"parent"=>120}

  create_table "ejabberd_pubsub_node_option", :id => false, :force => true do |t|
    t.integer "nodeid", :limit => 8
    t.text    "name"
    t.text    "val"
  end

  add_index "ejabberd_pubsub_node_option", ["nodeid"], :name => "i_pubsub_node_option_nodeid"

  create_table "ejabberd_pubsub_node_owner", :id => false, :force => true do |t|
    t.integer "nodeid", :limit => 8
    t.text    "owner"
  end

  add_index "ejabberd_pubsub_node_owner", ["nodeid"], :name => "i_pubsub_node_owner_nodeid"

  create_table "ejabberd_pubsub_state", :primary_key => "stateid", :force => true do |t|
    t.integer "nodeid",        :limit => 8
    t.text    "jid"
    t.string  "affiliation",   :limit => 1
    t.text    "subscriptions"
  end

  add_index "ejabberd_pubsub_state", ["jid"], :name => "i_pubsub_state_jid", :length => {"jid"=>60}
  add_index "ejabberd_pubsub_state", ["nodeid", "jid"], :name => "i_pubsub_state_tuple", :unique => true, :length => {"jid"=>60, "nodeid"=>nil}

  create_table "ejabberd_pubsub_subscription_opt", :id => false, :force => true do |t|
    t.text   "subid"
    t.string "opt_name",  :limit => 32
    t.text   "opt_value"
  end

  add_index "ejabberd_pubsub_subscription_opt", ["subid", "opt_name"], :name => "i_pubsub_subscription_opt", :unique => true, :length => {"opt_name"=>nil, "subid"=>32}

  create_table "ejabberd_roster_version", :primary_key => "username", :force => true do |t|
    t.text "version", :null => false
  end

  create_table "ejabberd_rostergroups", :id => false, :force => true do |t|
    t.string "username"
    t.string "jid",      :default => "", :null => false
    t.string "grp",                      :null => false
  end

  create_table "ejabberd_rosterusers", :id => false, :force => true do |t|
    t.string   "username"
    t.string   "jid",                       :default => "", :null => false
    t.string   "nick"
    t.string   "subscription", :limit => 1, :default => "", :null => false
    t.string   "ask",          :limit => 1, :default => "", :null => false
    t.string   "askmessage",   :limit => 0, :default => "", :null => false
    t.string   "server",       :limit => 1, :default => "", :null => false
    t.string   "subscribe",    :limit => 0, :default => "", :null => false
    t.string   "type",         :limit => 4, :default => "", :null => false
    t.datetime "created_at"
  end

  create_table "ejabberd_spool", :primary_key => "seq", :force => true do |t|
    t.string   "username",   :limit => 250, :null => false
    t.text     "xml",                       :null => false
    t.datetime "created_at",                :null => false
  end

  add_index "ejabberd_spool", ["seq"], :name => "seq", :unique => true
  add_index "ejabberd_spool", ["username"], :name => "i_despool"

  create_table "ejabberd_users", :primary_key => "username", :force => true do |t|
    t.text     "password",   :null => false
    t.datetime "created_at", :null => false
  end

  create_table "ejabberd_vcard", :primary_key => "username", :force => true do |t|
    t.text     "vcard",      :limit => 2147483647, :null => false
    t.datetime "created_at",                       :null => false
  end

  create_table "ejabberd_vcard_search", :primary_key => "lusername", :force => true do |t|
    t.string "username",  :limit => 250, :null => false
    t.text   "fn",                       :null => false
    t.string "lfn",       :limit => 250, :null => false
    t.text   "family",                   :null => false
    t.string "lfamily",   :limit => 250, :null => false
    t.text   "given",                    :null => false
    t.string "lgiven",    :limit => 250, :null => false
    t.text   "middle",                   :null => false
    t.string "lmiddle",   :limit => 250, :null => false
    t.text   "nickname",                 :null => false
    t.string "lnickname", :limit => 250, :null => false
    t.text   "bday",                     :null => false
    t.string "lbday",     :limit => 250, :null => false
    t.text   "ctry",                     :null => false
    t.string "lctry",     :limit => 250, :null => false
    t.text   "locality",                 :null => false
    t.string "llocality", :limit => 250, :null => false
    t.text   "email",                    :null => false
    t.string "lemail",    :limit => 250, :null => false
    t.text   "orgname",                  :null => false
    t.string "lorgname",  :limit => 250, :null => false
    t.text   "orgunit",                  :null => false
    t.string "lorgunit",  :limit => 250, :null => false
  end

  add_index "ejabberd_vcard_search", ["lbday"], :name => "i_vcard_search_lbday"
  add_index "ejabberd_vcard_search", ["lctry"], :name => "i_vcard_search_lctry"
  add_index "ejabberd_vcard_search", ["lemail"], :name => "i_vcard_search_lemail"
  add_index "ejabberd_vcard_search", ["lfamily"], :name => "i_vcard_search_lfamily"
  add_index "ejabberd_vcard_search", ["lfn"], :name => "i_vcard_search_lfn"
  add_index "ejabberd_vcard_search", ["lgiven"], :name => "i_vcard_search_lgiven"
  add_index "ejabberd_vcard_search", ["llocality"], :name => "i_vcard_search_llocality"
  add_index "ejabberd_vcard_search", ["lmiddle"], :name => "i_vcard_search_lmiddle"
  add_index "ejabberd_vcard_search", ["lnickname"], :name => "i_vcard_search_lnickname"
  add_index "ejabberd_vcard_search", ["lorgname"], :name => "i_vcard_search_lorgname"
  add_index "ejabberd_vcard_search", ["lorgunit"], :name => "i_vcard_search_lorgunit"

  create_table "invitations", :force => true do |t|
    t.text     "message"
    t.integer  "sender_id",    :null => false
    t.integer  "recipient_id", :null => false
    t.integer  "aspect_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["aspect_id"], :name => "index_invitations_on_aspect_id"
  add_index "invitations", ["recipient_id"], :name => "index_invitations_on_recipient_id"
  add_index "invitations", ["sender_id"], :name => "index_invitations_on_sender_id"

  create_table "likes", :force => true do |t|
    t.boolean  "positive",                              :default => true
    t.integer  "target_id"
    t.integer  "author_id"
    t.string   "guid"
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_type",             :limit => 60,                   :null => false
  end

  add_index "likes", ["author_id"], :name => "likes_author_id_fk"
  add_index "likes", ["guid"], :name => "index_likes_on_guid", :unique => true
  add_index "likes", ["target_id", "author_id", "target_type"], :name => "index_likes_on_target_id_and_author_id_and_target_type", :unique => true
  add_index "likes", ["target_id"], :name => "index_likes_on_post_id"

  create_table "mentions", :force => true do |t|
    t.integer "post_id",   :null => false
    t.integer "person_id", :null => false
  end

  add_index "mentions", ["person_id", "post_id"], :name => "index_mentions_on_person_id_and_post_id", :unique => true
  add_index "mentions", ["person_id"], :name => "index_mentions_on_person_id"
  add_index "mentions", ["post_id"], :name => "index_mentions_on_post_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id",         :null => false
    t.integer  "author_id",               :null => false
    t.string   "guid",                    :null => false
    t.text     "text",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "author_signature"
    t.text     "parent_author_signature"
  end

  add_index "messages", ["author_id"], :name => "index_messages_on_author_id"
  add_index "messages", ["conversation_id"], :name => "messages_conversation_id_fk"

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

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "authorization_id",               :null => false
    t.string   "access_token",     :limit => 32, :null => false
    t.string   "refresh_token",    :limit => 32
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_authorization_codes", :force => true do |t|
    t.integer  "authorization_id",               :null => false
    t.string   "code",             :limit => 32, :null => false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "redirect_uri"
  end

  create_table "oauth_authorizations", :force => true do |t|
    t.integer  "client_id",                         :null => false
    t.integer  "resource_owner_id"
    t.string   "resource_owner_type", :limit => 32
    t.string   "scope"
    t.datetime "expires_at"
  end

  add_index "oauth_authorizations", ["resource_owner_id", "resource_owner_type", "client_id"], :name => "index_oauth_authorizations_on_resource_owner_and_client_id", :unique => true

  create_table "oauth_clients", :force => true do |t|
    t.string "name",                 :limit => 127, :null => false
    t.text   "description",                         :null => false
    t.string "application_base_url", :limit => 127, :null => false
    t.string "icon_url",             :limit => 127, :null => false
    t.string "oauth_identifier",     :limit => 32,  :null => false
    t.string "oauth_secret",         :limit => 32,  :null => false
    t.string "nonce",                :limit => 64
    t.text   "public_key",                          :null => false
    t.text   "permissions_overview",                :null => false
  end

  add_index "oauth_clients", ["application_base_url"], :name => "index_oauth_clients_on_application_base_url", :unique => true
  add_index "oauth_clients", ["name"], :name => "index_oauth_clients_on_name", :unique => true
  add_index "oauth_clients", ["nonce"], :name => "index_oauth_clients_on_nonce", :unique => true

  create_table "people", :force => true do |t|
    t.string   "guid",                  :null => false
    t.text     "url",                   :null => false
    t.string   "diaspora_handle",       :null => false
    t.text     "serialized_public_key", :null => false
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["diaspora_handle"], :name => "index_people_on_diaspora_handle", :unique => true
  add_index "people", ["guid"], :name => "index_people_on_guid", :unique => true
  add_index "people", ["owner_id"], :name => "index_people_on_owner_id", :unique => true

  create_table "pod_stats", :force => true do |t|
    t.integer  "error_code"
    t.integer  "person_id"
    t.text     "error_message"
    t.integer  "pod_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pods", :force => true do |t|
    t.string   "host"
    t.boolean  "ssl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "post_visibilities", :force => true do |t|
    t.integer  "post_id",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     :default => false, :null => false
    t.integer  "contact_id",                    :null => false
  end

  add_index "post_visibilities", ["contact_id", "post_id"], :name => "index_post_visibilities_on_contact_id_and_post_id", :unique => true
  add_index "post_visibilities", ["contact_id"], :name => "index_post_visibilities_on_contact_id"
  add_index "post_visibilities", ["post_id", "hidden", "contact_id"], :name => "index_post_visibilities_on_post_id_and_hidden_and_contact_id", :unique => true
  add_index "post_visibilities", ["post_id"], :name => "index_post_visibilities_on_post_id"

  create_table "posts", :force => true do |t|
    t.integer  "author_id",                                              :null => false
    t.boolean  "public",                              :default => false, :null => false
    t.string   "diaspora_handle"
    t.string   "guid",                                                   :null => false
    t.boolean  "pending",                             :default => false, :null => false
    t.string   "type",                  :limit => 40,                    :null => false
    t.text     "text"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "processed_image"
    t.text     "youtube_titles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unprocessed_image"
    t.string   "object_url"
    t.string   "image_url"
    t.integer  "image_height"
    t.integer  "image_width"
    t.string   "provider_display_name"
    t.string   "actor_url"
    t.integer  "objectId"
    t.string   "root_guid",             :limit => 30
    t.string   "status_message_guid"
    t.integer  "likes_count",                         :default => 0
  end

  add_index "posts", ["author_id"], :name => "index_posts_on_person_id"
  add_index "posts", ["guid"], :name => "index_posts_on_guid", :unique => true
  add_index "posts", ["status_message_guid", "pending"], :name => "index_posts_on_status_message_guid_and_pending"
  add_index "posts", ["status_message_guid"], :name => "index_posts_on_status_message_guid"
  add_index "posts", ["type", "pending", "id"], :name => "index_posts_on_type_and_pending_and_id"

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
    t.string   "location"
    t.string   "full_name",        :limit => 70
  end

  add_index "profiles", ["full_name", "searchable"], :name => "index_profiles_on_full_name_and_searchable"
  add_index "profiles", ["full_name"], :name => "index_profiles_on_full_name"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "service_users", :force => true do |t|
    t.string   "uid",           :null => false
    t.string   "name",          :null => false
    t.string   "photo_url",     :null => false
    t.integer  "service_id",    :null => false
    t.integer  "person_id"
    t.integer  "contact_id"
    t.integer  "request_id"
    t.integer  "invitation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_users", ["service_id"], :name => "index_service_users_on_service_id"
  add_index "service_users", ["uid", "service_id"], :name => "index_service_users_on_uid_and_service_id", :unique => true

  create_table "services", :force => true do |t|
    t.string   "type",          :null => false
    t.integer  "user_id",       :null => false
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["user_id"], :name => "index_services_on_user_id"

  create_table "tag_followings", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 127
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 127
    t.string   "context",       :limit => 127
    t.datetime "created_at"
  end

  add_index "taggings", ["created_at"], :name => "index_taggings_on_created_at"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
  add_index "taggings", ["taggable_id", "taggable_type", "tag_id"], :name => "index_taggings_uniquely", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "user_preferences", :force => true do |t|
    t.string   "email_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.text     "serialized_private_key"
    t.integer  "invites",                               :default => 0,     :null => false
    t.boolean  "getting_started",                       :default => true,  :null => false
    t.boolean  "disable_mail",                          :default => false, :null => false
    t.string   "language"
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "invitation_token",       :limit => 60
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
    t.string   "invitation_service",     :limit => 127
    t.string   "invitation_identifier",  :limit => 127
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "authentication_token",   :limit => 30
    t.string   "unconfirmed_email"
    t.string   "confirm_email_token",    :limit => 30
    t.datetime "locked_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["invitation_service", "invitation_identifier"], :name => "index_users_on_invitation_service_and_invitation_identifier", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  add_foreign_key "aspect_memberships", "aspects", :name => "aspect_memberships_aspect_id_fk", :dependent => :delete
  add_foreign_key "aspect_memberships", "contacts", :name => "aspect_memberships_contact_id_fk", :dependent => :delete

  add_foreign_key "aspect_visibilities", "aspects", :name => "aspect_visibilities_aspect_id_fk", :dependent => :delete
  add_foreign_key "aspect_visibilities", "posts", :name => "aspect_visibilities_post_id_fk", :dependent => :delete

  add_foreign_key "comments", "people", :name => "comments_author_id_fk", :column => "author_id", :dependent => :delete
  add_foreign_key "comments", "posts", :name => "comments_post_id_fk", :dependent => :delete

  add_foreign_key "contacts", "people", :name => "contacts_person_id_fk", :dependent => :delete

  add_foreign_key "conversation_visibilities", "conversations", :name => "conversation_visibilities_conversation_id_fk", :dependent => :delete
  add_foreign_key "conversation_visibilities", "people", :name => "conversation_visibilities_person_id_fk", :dependent => :delete

  add_foreign_key "conversations", "people", :name => "conversations_author_id_fk", :column => "author_id", :dependent => :delete

  add_foreign_key "invitations", "users", :name => "invitations_recipient_id_fk", :column => "recipient_id", :dependent => :delete
  add_foreign_key "invitations", "users", :name => "invitations_sender_id_fk", :column => "sender_id", :dependent => :delete

  add_foreign_key "likes", "people", :name => "likes_author_id_fk", :column => "author_id", :dependent => :delete

  add_foreign_key "messages", "conversations", :name => "messages_conversation_id_fk", :dependent => :delete
  add_foreign_key "messages", "people", :name => "messages_author_id_fk", :column => "author_id", :dependent => :delete

  add_foreign_key "notification_actors", "notifications", :name => "notification_actors_notification_id_fk", :dependent => :delete

  add_foreign_key "post_visibilities", "contacts", :name => "post_visibilities_contact_id_fk", :dependent => :delete
  add_foreign_key "post_visibilities", "posts", :name => "post_visibilities_post_id_fk", :dependent => :delete

  add_foreign_key "posts", "people", :name => "posts_author_id_fk", :column => "author_id", :dependent => :delete

  add_foreign_key "profiles", "people", :name => "profiles_person_id_fk", :dependent => :delete

  add_foreign_key "services", "users", :name => "services_user_id_fk", :dependent => :delete

end
