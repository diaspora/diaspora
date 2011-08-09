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

ActiveRecord::Schema.define(:version => 0) do

  create_table "last", :primary_key => "username", :force => true do |t|
    t.text "seconds", :null => false
    t.text "state",   :null => false
  end

  create_table "privacy_default_list", :primary_key => "username", :force => true do |t|
    t.string "name", :limit => 250, :null => false
  end

  create_table "privacy_list", :force => true do |t|
    t.string    "username",   :limit => 250, :null => false
    t.string    "name",       :limit => 250, :null => false
    t.timestamp "created_at",                :null => false
  end

  add_index "privacy_list", ["id"], :name => "id", :unique => true
  add_index "privacy_list", ["username", "name"], :name => "i_privacy_list_username_name", :unique => true, :length => {"name"=>75, "username"=>75}
  add_index "privacy_list", ["username"], :name => "i_privacy_list_username"

  create_table "privacy_list_data", :id => false, :force => true do |t|
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

  create_table "private_storage", :id => false, :force => true do |t|
    t.string    "username",   :limit => 250, :null => false
    t.string    "namespace",  :limit => 250, :null => false
    t.text      "data",                      :null => false
    t.timestamp "created_at",                :null => false
  end

  add_index "private_storage", ["username", "namespace"], :name => "i_private_storage_username_namespace", :unique => true, :length => {"namespace"=>75, "username"=>75}
  add_index "private_storage", ["username"], :name => "i_private_storage_username"

  create_table "pubsub_item", :id => false, :force => true do |t|
    t.integer "nodeid",       :limit => 8
    t.text    "itemid"
    t.text    "publisher"
    t.text    "creation"
    t.text    "modification"
    t.text    "payload"
  end

  add_index "pubsub_item", ["itemid"], :name => "i_pubsub_item_itemid", :length => {"itemid"=>36}
  add_index "pubsub_item", ["nodeid", "itemid"], :name => "i_pubsub_item_tuple", :unique => true, :length => {"itemid"=>36, "nodeid"=>nil}

  create_table "pubsub_node", :primary_key => "nodeid", :force => true do |t|
    t.text "host"
    t.text "node"
    t.text "parent"
    t.text "type"
  end

  add_index "pubsub_node", ["host", "node"], :name => "i_pubsub_node_tuple", :unique => true, :length => {"node"=>120, "host"=>20}
  add_index "pubsub_node", ["parent"], :name => "i_pubsub_node_parent", :length => {"parent"=>120}

  create_table "pubsub_node_option", :id => false, :force => true do |t|
    t.integer "nodeid", :limit => 8
    t.text    "name"
    t.text    "val"
  end

  add_index "pubsub_node_option", ["nodeid"], :name => "i_pubsub_node_option_nodeid"

  create_table "pubsub_node_owner", :id => false, :force => true do |t|
    t.integer "nodeid", :limit => 8
    t.text    "owner"
  end

  add_index "pubsub_node_owner", ["nodeid"], :name => "i_pubsub_node_owner_nodeid"

  create_table "pubsub_state", :primary_key => "stateid", :force => true do |t|
    t.integer "nodeid",        :limit => 8
    t.text    "jid"
    t.string  "affiliation",   :limit => 1
    t.text    "subscriptions"
  end

  add_index "pubsub_state", ["jid"], :name => "i_pubsub_state_jid", :length => {"jid"=>60}
  add_index "pubsub_state", ["nodeid", "jid"], :name => "i_pubsub_state_tuple", :unique => true, :length => {"jid"=>60, "nodeid"=>nil}

  create_table "pubsub_subscription_opt", :id => false, :force => true do |t|
    t.text   "subid"
    t.string "opt_name",  :limit => 32
    t.text   "opt_value"
  end

  add_index "pubsub_subscription_opt", ["subid", "opt_name"], :name => "i_pubsub_subscription_opt", :unique => true, :length => {"opt_name"=>nil, "subid"=>32}

  create_table "roster_version", :primary_key => "username", :force => true do |t|
    t.text "version", :null => false
  end

  create_table "spool", :primary_key => "seq", :force => true do |t|
    t.string    "username",   :limit => 250, :null => false
    t.text      "xml",                       :null => false
    t.timestamp "created_at",                :null => false
  end

  add_index "spool", ["seq"], :name => "seq", :unique => true
  add_index "spool", ["username"], :name => "i_despool"

  create_table "users", :primary_key => "username", :force => true do |t|
    t.text      "password",   :null => false
    t.timestamp "created_at", :null => false
  end

  create_table "vcard", :primary_key => "username", :force => true do |t|
    t.text      "vcard",      :limit => 16777215, :null => false
    t.timestamp "created_at",                     :null => false
  end

  create_table "vcard_search", :primary_key => "lusername", :force => true do |t|
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

  add_index "vcard_search", ["lbday"], :name => "i_vcard_search_lbday"
  add_index "vcard_search", ["lctry"], :name => "i_vcard_search_lctry"
  add_index "vcard_search", ["lemail"], :name => "i_vcard_search_lemail"
  add_index "vcard_search", ["lfamily"], :name => "i_vcard_search_lfamily"
  add_index "vcard_search", ["lfn"], :name => "i_vcard_search_lfn"
  add_index "vcard_search", ["lgiven"], :name => "i_vcard_search_lgiven"
  add_index "vcard_search", ["llocality"], :name => "i_vcard_search_llocality"
  add_index "vcard_search", ["lmiddle"], :name => "i_vcard_search_lmiddle"
  add_index "vcard_search", ["lnickname"], :name => "i_vcard_search_lnickname"
  add_index "vcard_search", ["lorgname"], :name => "i_vcard_search_lorgname"
  add_index "vcard_search", ["lorgunit"], :name => "i_vcard_search_lorgunit"

end
