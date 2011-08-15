class CreateEjabberdDatabase < ActiveRecord::Migration
  def self.up
    create_table "ejabberd_last", :primary_key => "username", :force => true do |t|
      t.text "seconds", :null => false
      t.text "state",   :null => false
    end

    create_table "ejabberd_privacy_default_list", :primary_key => "username", :force => true do |t|
      t.string "name", :limit => 250, :null => false
    end
  
    create_table "ejabberd_privacy_list", :force => true do |t|
      t.string    "username",   :limit => 250, :null => false
      t.string    "name",       :limit => 250, :null => false
      t.timestamp "created_at",                :null => false
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
      t.string    "username",   :limit => 250, :null => false
      t.string    "namespace",  :limit => 250, :null => false
      t.text      "data",                      :null => false
      t.timestamp "created_at",                :null => false
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

    create_table "ejabberd_spool", :primary_key => "seq", :force => true do |t|
      t.string    "username",   :limit => 250, :null => false
      t.text      "xml",                       :null => false
      t.timestamp "created_at",                :null => false
    end

    add_index "ejabberd_spool", ["seq"], :name => "seq", :unique => true
    add_index "ejabberd_spool", ["username"], :name => "i_despool"

    create_table "ejabberd_users", :primary_key => "username", :force => true do |t|
      t.text      "password",   :null => false
      t.timestamp "created_at", :null => false
    end

    create_table "ejabberd_vcard", :primary_key => "username", :force => true do |t|
      t.text      "vcard",      :limit => 16777215, :null => false
      t.timestamp "created_at",                     :null => false
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

    execute("CREATE VIEW ejabberd_rosterusers AS SELECT username, SUBSTRING_INDEX(c.diaspora_handle,\':\',1) jid, IF(LENGTH(CONCAT(first_name, last_name))>0, CONCAT(first_name, \' \' ,last_name), SUBSTRING_INDEX(c.diaspora_handle,\'@\',1)) nick, \'B\' subscription, \'N\' ask, \'\' askmessage, \'N\' server, \'\' subscribe, \'item\' type, b.created_at FROM users AS a JOIN contacts AS b ON a.id = b.user_id JOIN people AS c ON b.person_id = c.id JOIN profiles AS d ON c.id = d.id WHERE b.sharing = 1 AND b.receiving = 1;")
    execute("CREATE VIEW ejabberd_rostergroups AS SELECT username, SUBSTRING_INDEX(e.diaspora_handle,\':\',1) jid, name grp FROM aspect_memberships AS a JOIN contacts AS b ON a.contact_id = b.id JOIN aspects AS c ON a.aspect_id = c.id JOIN users AS d ON d.id = b.user_id JOIN people AS e ON e.id = b.person_id;")
  end

  def self.down
    drop_table "ejabberd_last"
    drop_table "ejabberd_privacy_default_list"
    drop_table "ejabberd_privacy_list"
    drop_table "ejabberd_privacy_list_data"
    drop_table "ejabberd_private_storage"
    drop_table "ejabberd_pubsub_item"
    drop_table "ejabberd_pubsub_node"
    drop_table "ejabberd_pubsub_node_option"
    drop_table "ejabberd_pubsub_node_owner"
    drop_table "ejabberd_pubsub_state"
    drop_table "ejabberd_pubsub_subscription_opt"
    drop_table "ejabberd_roster_version"
    drop_table "ejabberd_spool"
    drop_table "ejabberd_users"
    drop_table "ejabberd_vcard"
    drop_table "ejabberd_vcard_search"
    execute("DROP VIEW ejabberd_rosterusers")
    execute("DROP VIEW ejabberd_rostergroups")
  end
end
