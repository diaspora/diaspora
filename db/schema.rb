# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161024231443) do

  create_table "account_deletions", force: :cascade do |t|
    t.string   "diaspora_handle", limit: 255
    t.integer  "person_id",       limit: 4
    t.datetime "completed_at"
  end

  create_table "aspect_memberships", force: :cascade do |t|
    t.integer  "aspect_id",  limit: 4, null: false
    t.integer  "contact_id", limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "aspect_memberships", ["aspect_id", "contact_id"], name: "index_aspect_memberships_on_aspect_id_and_contact_id", unique: true, using: :btree
  add_index "aspect_memberships", ["aspect_id"], name: "index_aspect_memberships_on_aspect_id", using: :btree
  add_index "aspect_memberships", ["contact_id"], name: "index_aspect_memberships_on_contact_id", using: :btree

  create_table "aspect_visibilities", force: :cascade do |t|
    t.integer "shareable_id",   limit: 4,                    null: false
    t.integer "aspect_id",      limit: 4,                    null: false
    t.string  "shareable_type", limit: 255, default: "Post", null: false
  end

  add_index "aspect_visibilities", ["aspect_id"], name: "index_aspect_visibilities_on_aspect_id", using: :btree
  add_index "aspect_visibilities", ["shareable_id", "shareable_type", "aspect_id"], name: "shareable_and_aspect_id", length: {"shareable_id"=>nil, "shareable_type"=>189, "aspect_id"=>nil}, using: :btree
  add_index "aspect_visibilities", ["shareable_id", "shareable_type"], name: "index_aspect_visibilities_on_shareable_id_and_shareable_type", length: {"shareable_id"=>nil, "shareable_type"=>190}, using: :btree

  create_table "aspects", force: :cascade do |t|
    t.string   "name",             limit: 255,                 null: false
    t.integer  "user_id",          limit: 4,                   null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "contacts_visible",             default: true,  null: false
    t.integer  "order_id",         limit: 4
    t.boolean  "chat_enabled",                 default: false
    t.boolean  "post_default",                 default: true
  end

  add_index "aspects", ["user_id", "contacts_visible"], name: "index_aspects_on_user_id_and_contacts_visible", using: :btree
  add_index "aspects", ["user_id"], name: "index_aspects_on_user_id", using: :btree

  create_table "authorizations", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "o_auth_application_id", limit: 4
    t.string   "refresh_token",         limit: 255
    t.string   "code",                  limit: 255
    t.string   "redirect_uri",          limit: 255
    t.string   "nonce",                 limit: 255
    t.string   "scopes",                limit: 255
    t.boolean  "code_used",                         default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "authorizations", ["o_auth_application_id"], name: "index_authorizations_on_o_auth_application_id", using: :btree
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.integer "user_id",   limit: 4
    t.integer "person_id", limit: 4
  end

  create_table "chat_contacts", force: :cascade do |t|
    t.integer "user_id",      limit: 4,   null: false
    t.string  "jid",          limit: 255, null: false
    t.string  "name",         limit: 255
    t.string  "ask",          limit: 128
    t.string  "subscription", limit: 128, null: false
  end

  add_index "chat_contacts", ["user_id", "jid"], name: "index_chat_contacts_on_user_id_and_jid", unique: true, length: {"user_id"=>nil, "jid"=>190}, using: :btree

  create_table "chat_fragments", force: :cascade do |t|
    t.integer "user_id",   limit: 4,     null: false
    t.string  "root",      limit: 256,   null: false
    t.string  "namespace", limit: 256,   null: false
    t.text    "xml",       limit: 65535, null: false
  end

  add_index "chat_fragments", ["user_id"], name: "index_chat_fragments_on_user_id", unique: true, using: :btree

  create_table "chat_offline_messages", force: :cascade do |t|
    t.string   "from",       limit: 255,   null: false
    t.string   "to",         limit: 255,   null: false
    t.text     "message",    limit: 65535, null: false
    t.datetime "created_at",               null: false
  end

  create_table "comment_signatures", id: false, force: :cascade do |t|
    t.integer "comment_id",         limit: 4,     null: false
    t.text    "author_signature",   limit: 65535, null: false
    t.integer "signature_order_id", limit: 4,     null: false
    t.text    "additional_data",    limit: 65535
  end

  add_index "comment_signatures", ["comment_id"], name: "index_comment_signatures_on_comment_id", unique: true, using: :btree
  add_index "comment_signatures", ["signature_order_id"], name: "comment_signatures_signature_orders_id_fk", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "text",             limit: 65535,                  null: false
    t.integer  "commentable_id",   limit: 4,                      null: false
    t.integer  "author_id",        limit: 4,                      null: false
    t.string   "guid",             limit: 255,                    null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "likes_count",      limit: 4,     default: 0,      null: false
    t.string   "commentable_type", limit: 60,    default: "Post", null: false
  end

  add_index "comments", ["author_id"], name: "index_comments_on_person_id", using: :btree
  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["guid"], name: "index_comments_on_guid", unique: true, length: {"guid"=>191}, using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,                 null: false
    t.integer  "person_id",  limit: 4,                 null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "sharing",              default: false, null: false
    t.boolean  "receiving",            default: false, null: false
  end

  add_index "contacts", ["person_id"], name: "index_contacts_on_person_id", using: :btree
  add_index "contacts", ["user_id", "person_id"], name: "index_contacts_on_user_id_and_person_id", unique: true, using: :btree

  create_table "conversation_visibilities", force: :cascade do |t|
    t.integer  "conversation_id", limit: 4,             null: false
    t.integer  "person_id",       limit: 4,             null: false
    t.integer  "unread",          limit: 4, default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "conversation_visibilities", ["conversation_id", "person_id"], name: "index_conversation_visibilities_usefully", unique: true, using: :btree
  add_index "conversation_visibilities", ["conversation_id"], name: "index_conversation_visibilities_on_conversation_id", using: :btree
  add_index "conversation_visibilities", ["person_id"], name: "index_conversation_visibilities_on_person_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "subject",    limit: 255
    t.string   "guid",       limit: 255, null: false
    t.integer  "author_id",  limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "conversations", ["author_id"], name: "conversations_author_id_fk", using: :btree
  add_index "conversations", ["guid"], name: "index_conversations_on_guid", unique: true, length: {"guid"=>191}, using: :btree

  create_table "invitation_codes", force: :cascade do |t|
    t.string   "token",      limit: 255
    t.integer  "user_id",    limit: 4
    t.integer  "count",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "like_signatures", id: false, force: :cascade do |t|
    t.integer "like_id",            limit: 4,     null: false
    t.text    "author_signature",   limit: 65535, null: false
    t.integer "signature_order_id", limit: 4,     null: false
    t.text    "additional_data",    limit: 65535
  end

  add_index "like_signatures", ["like_id"], name: "index_like_signatures_on_like_id", unique: true, using: :btree
  add_index "like_signatures", ["signature_order_id"], name: "like_signatures_signature_orders_id_fk", using: :btree

  create_table "likes", force: :cascade do |t|
    t.boolean  "positive",                default: true
    t.integer  "target_id",   limit: 4
    t.integer  "author_id",   limit: 4
    t.string   "guid",        limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "target_type", limit: 60,                 null: false
  end

  add_index "likes", ["author_id"], name: "likes_author_id_fk", using: :btree
  add_index "likes", ["guid"], name: "index_likes_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "likes", ["target_id", "author_id", "target_type"], name: "index_likes_on_target_id_and_author_id_and_target_type", unique: true, using: :btree
  add_index "likes", ["target_id"], name: "index_likes_on_post_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "address",           limit: 255
    t.string   "lat",               limit: 255
    t.string   "lng",               limit: 255
    t.integer  "status_message_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "mentions", force: :cascade do |t|
    t.integer "post_id",   limit: 4, null: false
    t.integer "person_id", limit: 4, null: false
  end

  add_index "mentions", ["person_id", "post_id"], name: "index_mentions_on_person_id_and_post_id", unique: true, using: :btree
  add_index "mentions", ["person_id"], name: "index_mentions_on_person_id", using: :btree
  add_index "mentions", ["post_id"], name: "index_mentions_on_post_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id",  limit: 4,     null: false
    t.integer  "author_id",        limit: 4,     null: false
    t.string   "guid",             limit: 255,   null: false
    t.text     "text",             limit: 65535, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "author_signature", limit: 65535
  end

  add_index "messages", ["author_id"], name: "index_messages_on_author_id", using: :btree
  add_index "messages", ["conversation_id"], name: "messages_conversation_id_fk", using: :btree
  add_index "messages", ["guid"], name: "index_messages_on_guid", unique: true, length: {"guid"=>191}, using: :btree

  create_table "notification_actors", force: :cascade do |t|
    t.integer  "notification_id", limit: 4
    t.integer  "person_id",       limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "notification_actors", ["notification_id", "person_id"], name: "index_notification_actors_on_notification_id_and_person_id", unique: true, using: :btree
  add_index "notification_actors", ["notification_id"], name: "index_notification_actors_on_notification_id", using: :btree
  add_index "notification_actors", ["person_id"], name: "index_notification_actors_on_person_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "target_type",  limit: 255
    t.integer  "target_id",    limit: 4
    t.integer  "recipient_id", limit: 4,                  null: false
    t.boolean  "unread",                   default: true, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "type",         limit: 255
  end

  add_index "notifications", ["recipient_id"], name: "index_notifications_on_recipient_id", using: :btree
  add_index "notifications", ["target_id"], name: "index_notifications_on_target_id", using: :btree
  add_index "notifications", ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id", length: {"target_type"=>190, "target_id"=>nil}, using: :btree

  create_table "o_auth_access_tokens", force: :cascade do |t|
    t.integer  "authorization_id", limit: 4
    t.string   "token",            limit: 255
    t.datetime "expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "o_auth_access_tokens", ["authorization_id"], name: "index_o_auth_access_tokens_on_authorization_id", using: :btree
  add_index "o_auth_access_tokens", ["token"], name: "index_o_auth_access_tokens_on_token", unique: true, length: {"token"=>191}, using: :btree

  create_table "o_auth_applications", force: :cascade do |t|
    t.integer  "user_id",                    limit: 4
    t.string   "client_id",                  limit: 255
    t.string   "client_secret",              limit: 255
    t.string   "client_name",                limit: 255
    t.text     "redirect_uris",              limit: 65535
    t.string   "response_types",             limit: 255
    t.string   "grant_types",                limit: 255
    t.string   "application_type",           limit: 255,   default: "web"
    t.string   "contacts",                   limit: 255
    t.string   "logo_uri",                   limit: 255
    t.string   "client_uri",                 limit: 255
    t.string   "policy_uri",                 limit: 255
    t.string   "tos_uri",                    limit: 255
    t.string   "sector_identifier_uri",      limit: 255
    t.string   "token_endpoint_auth_method", limit: 255
    t.text     "jwks",                       limit: 65535
    t.string   "jwks_uri",                   limit: 255
    t.boolean  "ppid",                                     default: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "o_auth_applications", ["client_id"], name: "index_o_auth_applications_on_client_id", unique: true, length: {"client_id"=>191}, using: :btree
  add_index "o_auth_applications", ["user_id"], name: "index_o_auth_applications_on_user_id", using: :btree

  create_table "o_embed_caches", force: :cascade do |t|
    t.string "url",  limit: 1024,  null: false
    t.text   "data", limit: 65535, null: false
  end

  add_index "o_embed_caches", ["url"], name: "index_o_embed_caches_on_url", length: {"url"=>191}, using: :btree

  create_table "open_graph_caches", force: :cascade do |t|
    t.string "title",       limit: 255
    t.string "ob_type",     limit: 255
    t.text   "image",       limit: 65535
    t.text   "url",         limit: 65535
    t.text   "description", limit: 65535
    t.text   "video_url",   limit: 65535
  end

  create_table "participations", force: :cascade do |t|
    t.string   "guid",        limit: 255
    t.integer  "target_id",   limit: 4
    t.string   "target_type", limit: 60,              null: false
    t.integer  "author_id",   limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "count",       limit: 4,   default: 1, null: false
  end

  add_index "participations", ["author_id"], name: "index_participations_on_author_id", using: :btree
  add_index "participations", ["guid"], name: "index_participations_on_guid", length: {"guid"=>191}, using: :btree
  add_index "participations", ["target_id", "target_type", "author_id"], name: "index_participations_on_target_id_and_target_type_and_author_id", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "guid",                  limit: 255,                   null: false
    t.string   "diaspora_handle",       limit: 255,                   null: false
    t.text     "serialized_public_key", limit: 65535,                 null: false
    t.integer  "owner_id",              limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "closed_account",                      default: false
    t.integer  "fetch_status",          limit: 4,     default: 0
    t.integer  "pod_id",                limit: 4
  end

  add_index "people", ["diaspora_handle"], name: "index_people_on_diaspora_handle", unique: true, length: {"diaspora_handle"=>191}, using: :btree
  add_index "people", ["guid"], name: "index_people_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "people", ["owner_id"], name: "index_people_on_owner_id", unique: true, using: :btree
  add_index "people", ["pod_id"], name: "people_pod_id_fk", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "author_id",           limit: 4,                     null: false
    t.boolean  "public",                            default: false, null: false
    t.string   "guid",                limit: 255,                   null: false
    t.boolean  "pending",                           default: false, null: false
    t.text     "text",                limit: 65535
    t.text     "remote_photo_path",   limit: 65535
    t.string   "remote_photo_name",   limit: 255
    t.string   "random_string",       limit: 255
    t.string   "processed_image",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unprocessed_image",   limit: 255
    t.string   "status_message_guid", limit: 255
    t.integer  "comments_count",      limit: 4
    t.integer  "height",              limit: 4
    t.integer  "width",               limit: 4
  end

  add_index "photos", ["guid"], name: "index_photos_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "photos", ["status_message_guid"], name: "index_photos_on_status_message_guid", length: {"status_message_guid"=>191}, using: :btree

  create_table "pods", force: :cascade do |t|
    t.string   "host",            limit: 255,                                 null: false
    t.boolean  "ssl"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "status",          limit: 4,   default: 0
    t.datetime "checked_at",                  default: '1970-01-01 00:00:00'
    t.datetime "offline_since"
    t.integer  "response_time",   limit: 4,   default: -1
    t.string   "software",        limit: 255
    t.string   "error",           limit: 255
    t.integer  "port",            limit: 4
    t.boolean  "blocked",                     default: false
    t.boolean  "scheduled_check",             default: false,                 null: false
  end

  add_index "pods", ["checked_at"], name: "index_pods_on_checked_at", using: :btree
  add_index "pods", ["host", "port"], name: "index_pods_on_host_and_port", unique: true, length: {"host"=>190, "port"=>nil}, using: :btree
  add_index "pods", ["offline_since"], name: "index_pods_on_offline_since", using: :btree
  add_index "pods", ["status"], name: "index_pods_on_status", using: :btree

  create_table "poll_answers", force: :cascade do |t|
    t.string  "answer",     limit: 255,             null: false
    t.integer "poll_id",    limit: 4,               null: false
    t.string  "guid",       limit: 255
    t.integer "vote_count", limit: 4,   default: 0
  end

  add_index "poll_answers", ["guid"], name: "index_poll_answers_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "poll_answers", ["poll_id"], name: "index_poll_answers_on_poll_id", using: :btree

  create_table "poll_participation_signatures", id: false, force: :cascade do |t|
    t.integer "poll_participation_id", limit: 4,     null: false
    t.text    "author_signature",      limit: 65535, null: false
    t.integer "signature_order_id",    limit: 4,     null: false
    t.text    "additional_data",       limit: 65535
  end

  add_index "poll_participation_signatures", ["poll_participation_id"], name: "index_poll_participation_signatures_on_poll_participation_id", unique: true, using: :btree
  add_index "poll_participation_signatures", ["signature_order_id"], name: "poll_participation_signatures_signature_orders_id_fk", using: :btree

  create_table "poll_participations", force: :cascade do |t|
    t.integer  "poll_answer_id", limit: 4,   null: false
    t.integer  "author_id",      limit: 4,   null: false
    t.integer  "poll_id",        limit: 4,   null: false
    t.string   "guid",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_participations", ["guid"], name: "index_poll_participations_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "poll_participations", ["poll_id"], name: "index_poll_participations_on_poll_id", using: :btree

  create_table "polls", force: :cascade do |t|
    t.string   "question",          limit: 255, null: false
    t.integer  "status_message_id", limit: 4,   null: false
    t.boolean  "status"
    t.string   "guid",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "polls", ["guid"], name: "index_polls_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "polls", ["status_message_id"], name: "index_polls_on_status_message_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "author_id",             limit: 4,                     null: false
    t.boolean  "public",                              default: false, null: false
    t.string   "guid",                  limit: 255,                   null: false
    t.string   "type",                  limit: 40,                    null: false
    t.text     "text",                  limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "provider_display_name", limit: 255
    t.string   "root_guid",             limit: 255
    t.integer  "likes_count",           limit: 4,     default: 0
    t.integer  "comments_count",        limit: 4,     default: 0
    t.integer  "o_embed_cache_id",      limit: 4
    t.integer  "reshares_count",        limit: 4,     default: 0
    t.datetime "interacted_at"
    t.string   "facebook_id",           limit: 255
    t.string   "tweet_id",              limit: 255
    t.integer  "open_graph_cache_id",   limit: 4
    t.text     "tumblr_ids",            limit: 65535
  end

  add_index "posts", ["author_id", "root_guid"], name: "index_posts_on_author_id_and_root_guid", unique: true, length: {"author_id"=>nil, "root_guid"=>190}, using: :btree
  add_index "posts", ["author_id"], name: "index_posts_on_person_id", using: :btree
  add_index "posts", ["guid"], name: "index_posts_on_guid", unique: true, length: {"guid"=>191}, using: :btree
  add_index "posts", ["id", "type", "created_at"], name: "index_posts_on_id_and_type_and_created_at", using: :btree
  add_index "posts", ["id", "type"], name: "index_posts_on_id_and_type", using: :btree
  add_index "posts", ["root_guid"], name: "index_posts_on_root_guid", length: {"root_guid"=>191}, using: :btree
  add_index "posts", ["tweet_id"], name: "index_posts_on_tweet_id", length: {"tweet_id"=>191}, using: :btree

  create_table "ppid", force: :cascade do |t|
    t.integer "o_auth_application_id", limit: 4
    t.integer "user_id",               limit: 4
    t.string  "guid",                  limit: 32
    t.string  "string",                limit: 32
    t.string  "identifier",            limit: 255
  end

  add_index "ppid", ["o_auth_application_id"], name: "index_ppid_on_o_auth_application_id", using: :btree
  add_index "ppid", ["user_id"], name: "index_ppid_on_user_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "diaspora_handle",  limit: 255
    t.string   "first_name",       limit: 127
    t.string   "last_name",        limit: 127
    t.string   "image_url",        limit: 255
    t.string   "image_url_small",  limit: 255
    t.string   "image_url_medium", limit: 255
    t.date     "birthday"
    t.string   "gender",           limit: 255
    t.text     "bio",              limit: 65535
    t.boolean  "searchable",                     default: true,  null: false
    t.integer  "person_id",        limit: 4,                     null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "location",         limit: 255
    t.string   "full_name",        limit: 70
    t.boolean  "nsfw",                           default: false
    t.boolean  "public_details",                 default: false
  end

  add_index "profiles", ["full_name", "searchable"], name: "index_profiles_on_full_name_and_searchable", using: :btree
  add_index "profiles", ["full_name"], name: "index_profiles_on_full_name", using: :btree
  add_index "profiles", ["person_id"], name: "index_profiles_on_person_id", using: :btree

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message",    limit: 65535
    t.string   "username",   limit: 255
    t.integer  "item",       limit: 4
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", length: {"item"=>nil, "table"=>188, "month"=>nil, "year"=>nil}, using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "item_id",    limit: 4,                     null: false
    t.string   "item_type",  limit: 255,                   null: false
    t.boolean  "reviewed",                 default: false
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4,                     null: false
  end

  add_index "reports", ["item_id"], name: "index_reports_on_item_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "person_id",  limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "services", force: :cascade do |t|
    t.string   "type",          limit: 127, null: false
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "uid",           limit: 127
    t.string   "access_token",  limit: 255
    t.string   "access_secret", limit: 255
    t.string   "nickname",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "services", ["type", "uid"], name: "index_services_on_type_and_uid", length: {"type"=>64, "uid"=>nil}, using: :btree
  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree

  create_table "share_visibilities", force: :cascade do |t|
    t.integer "shareable_id",   limit: 4,                   null: false
    t.boolean "hidden",                    default: false,  null: false
    t.string  "shareable_type", limit: 60, default: "Post", null: false
    t.integer "user_id",        limit: 4,                   null: false
  end

  add_index "share_visibilities", ["shareable_id", "shareable_type", "hidden", "user_id"], name: "shareable_and_hidden_and_user_id", using: :btree
  add_index "share_visibilities", ["shareable_id", "shareable_type", "user_id"], name: "shareable_and_user_id", unique: true, using: :btree
  add_index "share_visibilities", ["shareable_id"], name: "index_post_visibilities_on_post_id", using: :btree
  add_index "share_visibilities", ["user_id"], name: "index_share_visibilities_on_user_id", using: :btree

  create_table "signature_orders", force: :cascade do |t|
    t.string "order", limit: 255, null: false
  end

  add_index "signature_orders", ["order"], name: "index_signature_orders_on_order", unique: true, length: {"order"=>191}, using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 12
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "tag_followings", force: :cascade do |t|
    t.integer  "tag_id",     limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "tag_followings", ["tag_id", "user_id"], name: "index_tag_followings_on_tag_id_and_user_id", unique: true, using: :btree
  add_index "tag_followings", ["tag_id"], name: "index_tag_followings_on_tag_id", using: :btree
  add_index "tag_followings", ["user_id"], name: "index_tag_followings_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 127
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 127
    t.string   "context",       limit: 127
    t.datetime "created_at"
  end

  add_index "taggings", ["created_at"], name: "index_taggings_on_created_at", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", length: {"taggable_id"=>nil, "taggable_type"=>95, "context"=>95}, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tag_id"], name: "index_taggings_uniquely", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, length: {"name"=>191}, using: :btree

  create_table "user_preferences", force: :cascade do |t|
    t.string   "email_type", limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                           limit: 255,                   null: false
    t.text     "serialized_private_key",             limit: 65535
    t.boolean  "getting_started",                                  default: true,  null: false
    t.boolean  "disable_mail",                                     default: false, null: false
    t.string   "language",                           limit: 255
    t.string   "email",                              limit: 255,   default: "",    null: false
    t.string   "encrypted_password",                 limit: 255,   default: "",    null: false
    t.string   "reset_password_token",               limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                 limit: 255
    t.string   "last_sign_in_ip",                    limit: 255
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "invited_by_id",                      limit: 4
    t.string   "authentication_token",               limit: 30
    t.string   "unconfirmed_email",                  limit: 255
    t.string   "confirm_email_token",                limit: 30
    t.datetime "locked_at"
    t.boolean  "show_community_spotlight_in_stream",               default: true,  null: false
    t.boolean  "auto_follow_back",                                 default: false
    t.integer  "auto_follow_back_aspect_id",         limit: 4
    t.text     "hidden_shareables",                  limit: 65535
    t.datetime "reset_password_sent_at"
    t.datetime "last_seen"
    t.datetime "remove_after"
    t.string   "export",                             limit: 255
    t.datetime "exported_at"
    t.boolean  "exporting",                                        default: false
    t.boolean  "strip_exif",                                       default: true
    t.string   "exported_photos_file",               limit: 255
    t.datetime "exported_photos_at"
    t.boolean  "exporting_photos",                                 default: false
    t.string   "color_theme",                        limit: 255
    t.boolean  "post_default_public",                              default: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, length: {"email"=>191}, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, length: {"username"=>191}, using: :btree

  add_foreign_key "aspect_memberships", "aspects", name: "aspect_memberships_aspect_id_fk", on_delete: :cascade
  add_foreign_key "aspect_memberships", "contacts", name: "aspect_memberships_contact_id_fk", on_delete: :cascade
  add_foreign_key "aspect_visibilities", "aspects", name: "aspect_visibilities_aspect_id_fk", on_delete: :cascade
  add_foreign_key "authorizations", "o_auth_applications"
  add_foreign_key "authorizations", "users"
  add_foreign_key "comment_signatures", "comments", name: "comment_signatures_comment_id_fk", on_delete: :cascade
  add_foreign_key "comment_signatures", "signature_orders", name: "comment_signatures_signature_orders_id_fk"
  add_foreign_key "comments", "people", column: "author_id", name: "comments_author_id_fk", on_delete: :cascade
  add_foreign_key "contacts", "people", name: "contacts_person_id_fk", on_delete: :cascade
  add_foreign_key "conversation_visibilities", "conversations", name: "conversation_visibilities_conversation_id_fk", on_delete: :cascade
  add_foreign_key "conversation_visibilities", "people", name: "conversation_visibilities_person_id_fk", on_delete: :cascade
  add_foreign_key "conversations", "people", column: "author_id", name: "conversations_author_id_fk", on_delete: :cascade
  add_foreign_key "like_signatures", "likes", name: "like_signatures_like_id_fk", on_delete: :cascade
  add_foreign_key "like_signatures", "signature_orders", name: "like_signatures_signature_orders_id_fk"
  add_foreign_key "likes", "people", column: "author_id", name: "likes_author_id_fk", on_delete: :cascade
  add_foreign_key "messages", "conversations", name: "messages_conversation_id_fk", on_delete: :cascade
  add_foreign_key "messages", "people", column: "author_id", name: "messages_author_id_fk", on_delete: :cascade
  add_foreign_key "notification_actors", "notifications", name: "notification_actors_notification_id_fk", on_delete: :cascade
  add_foreign_key "o_auth_access_tokens", "authorizations"
  add_foreign_key "o_auth_applications", "users"
  add_foreign_key "people", "pods", name: "people_pod_id_fk", on_delete: :cascade
  add_foreign_key "poll_participation_signatures", "poll_participations", name: "poll_participation_signatures_poll_participation_id_fk", on_delete: :cascade
  add_foreign_key "poll_participation_signatures", "signature_orders", name: "poll_participation_signatures_signature_orders_id_fk"
  add_foreign_key "posts", "people", column: "author_id", name: "posts_author_id_fk", on_delete: :cascade
  add_foreign_key "ppid", "o_auth_applications"
  add_foreign_key "ppid", "users"
  add_foreign_key "profiles", "people", name: "profiles_person_id_fk", on_delete: :cascade
  add_foreign_key "services", "users", name: "services_user_id_fk", on_delete: :cascade
  add_foreign_key "share_visibilities", "users", name: "share_visibilities_user_id_fk", on_delete: :cascade
end
