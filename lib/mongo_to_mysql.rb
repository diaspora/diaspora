#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'json'
require 'csv'
class MongoToMysql
  def dirname
    "tmp/export-for-mysql"
  end
  def dirpath
    "#{Rails.root}/#{dirname}"
  end
  def make_dir
    `mkdir -p #{dirname}/json`
    `mkdir -p #{dirname}/csv`
  end
  def db_name
    "diaspora-#{Rails.env}"
  end
  def models
    @models ||= [ {:name => :aspects},
      {:name => :comments},
      {:name => :contacts},
      {:name => :invitations},
      {:name => :notifications},
      {:name => :people},
      {:name => :posts},
      {:name => :requests},
      {:name => :users},
    ]
  end
  def id_sed
    @id_sed = sed_replace('{\ \"$oid\"\ :\ \(\"[^"]*\"\)\ }')
  end
  def date_sed
    @date_sed = sed_replace('{\ \"$date\"\ :\ \([0-9]*\)\ }')
  end
  def sed_replace(regex)
    "sed 's/#{regex}/\\1/g'"
  end
  def json_for_model model_name
    "mongoexport -d #{db_name} -c #{model_name} | #{id_sed} | #{date_sed}"
  end
  def write_json_export
    models.each do |model|
      filename ="#{dirpath}/json/#{model[:name]}.json"
      model[:json_file] = filename
      `#{json_for_model(model[:name])} > #{filename}`
      debug "#{model[:name]} exported to #{dirname}/json/#{model[:name]}.json"
    end
    debug "Json export complete."
  end
  def debug string
    if ['development', 'production'].include?(Rails.env)
      puts string
    end
    Rails.logger.debug(string) if Rails.logger
  end
  def convert_json_files
    models.each do |model|
      self.send("#{model[:name]}_json_to_csv".to_sym, model)
    end
  end
  def generic_json_to_csv model_hash
    debug "Converting #{model_hash[:name]} json to csv"
    json_file = File.open(model_hash[:json_file])

    csv = CSV.open("#{dirpath}/csv/#{model_hash[:name]}.csv",'w')
    csv << model_hash[:attrs]

    json_file.each do |aspect_json|
      hash = JSON.parse(aspect_json)
      csv << yield(hash)
    end
    json_file.close
    csv.close
  end
  def comments_json_to_csv model_hash
    model_hash[:attrs] = ["mongo_id", "post_mongo_id", "person_mongo_id", "diaspora_handle", "text", "youtube_titles"]
    generic_json_to_csv(model_hash) do |hash|
      [hash["_id"], hash["post_id"], hash["person_id"], hash["diaspora_handle"], hash["text"], hash["youtube_titles"]]
    end
  end
  def contacts_json_to_csv model_hash
    model_hash[:main_attrs] = ["mongo_id", "user_mongo_id", "person_mongo_id", "pending", "created_at", "updated_at"]
    #Post Visibilities
    model_hash[:join_table_name] = :aspect_memberships
    model_hash[:join_table_attrs] = ["contact_mongo_id", "aspect_mongo_id"]

    generic_json_to_two_csvs(model_hash) do |hash|
      main_row = [hash["_id"], hash["user_id"], hash["person_id"], hash["pending"], hash["created_at"], hash["updated_at"]]
      aspect_membership_rows = hash["aspect_ids"].map{|id| [hash["_id"],id]}
      [main_row, aspect_membership_rows]
    end
    #Also writes the aspect memberships csv
  end
  def invitations_json_to_csv model_hash
    model_hash[:attrs] = ["mongo_id", "recipient_mongo_id", "sender_mongo_id", "aspect_mongo_id", "message"]
    generic_json_to_csv(model_hash) do |hash|
      [hash["_id"], hash["to_id"], hash["from_id"], hash["into_id"], hash["message"]]
    end
  end
  def notifications_json_to_csv model_hash
    model_hash[:attrs] = ["mongo_id", "target_id", "target_type", "unread"]
    generic_json_to_csv(model_hash) do |hash|
      [hash["_id"], hash["target_id"], hash["kind"], hash["unread"]]
    end
  end
  def people_json_to_csv model_hash
    model_hash[:attrs] = ["created_at", "updated_at", "serialized_public_key", "url", "mongo_id", "owner_mongo_id", "diaspora_handle"]
    model_hash[:profile_attrs] = ["image_url_medium", "searchable", "image_url", "person_mongo_id", "gender", "diaspora_handle", "birthday", "last_name", "bio", "image_url_small", "first_name"]
    #Also writes the profiles csv

    debug "Converting #{model_hash[:name]} json to csv"
    json_file = File.open(model_hash[:json_file])

    people_csv = CSV.open("#{dirpath}/csv/#{model_hash[:name]}.csv",'w')
    people_csv << model_hash[:attrs]

    profiles_csv = CSV.open("#{dirpath}/csv/profiles.csv",'w')
    profiles_csv << model_hash[:profile_attrs]

    json_file.each do |aspect_json|
      hash = JSON.parse(aspect_json)
      person_row = model_hash[:attrs].map do |attr_name|
        attr_name = attr_name.gsub("mongo_", "")
        hash[attr_name]
      end
      people_csv << person_row

      profile_row = model_hash[:profile_attrs].map do |attr_name|
        attr_name = attr_name.gsub("mongo_", "")
        hash["profile"][attr_name]
      end
      profiles_csv << person_row
    end
    json_file.close
    people_csv.close
    profiles_csv.close
  end
  def posts_json_to_csv model_hash
    model_hash[:attrs] =["youtube_titles", "pending", "created_at", "public", "updated_at", "status_message_mongo_id", "caption", "remote_photo_path", "random_string", "image", "mongo_id", "type", "diaspora_handle", "person_mongo_id", "message" ]
    generic_json_to_csv(model_hash) do |hash|
      mongo_attrs = ["youtube_titles", "pending", "created_at", "public", "updated_at", "status_message_id", "caption", "remote_photo_path", "random_string", "image", "_id", "_type", "diaspora_handle", "person_id", "message" ]
      mongo_attrs.map{|attr_name| hash[attr_name]}
    end
    #has to handle the polymorphic stuff
  end
  def requests_json_to_csv model_hash
    model_hash[:attrs] = ["mongo_id", "recipient_mongo_id", "sender_mongo_id", "aspect_mongo_id"]
    generic_json_to_csv(model_hash) do |hash|
      [hash["_id"], hash["to_id"], hash["from_id"], hash["into_id"]]
    end
  end
  def users_json_to_csv model_hash
    model_hash[:attrs] = ["mongo_id", "username", "serialized_private_key", "encrypted_password", "invites", "invitation_token", "invitation_sent_at", "getting_started", "disable_mail", "language", "last_sign_in_ip", "last_sign_in_at", "reset_password_token", "password_salt"]
    generic_json_to_csv(model_hash) do |hash|
      [hash["_id"], hash["username"], hash["serialized_private_key"], hash["encrypted_password"], hash["invites"], hash["invitation_token"], hash["invitation_sent_at"], hash["getting_started"], hash["disable_mail"], hash["language"], hash["last_sign_in_ip"], hash["last_sign_in_at"], hash["reset_password_token"], hash["password_salt"]]
    end
  end
  def aspects_json_to_csv model_hash
    debug "Converting aspects json to aspects and post_visibilities csvs"
    model_hash[:main_attrs] = ["mongo_id", "name", "created_at", "updated_at"]
    #Post Visibilities
    model_hash[:join_table_name] = :post_visibilities
    model_hash[:join_table_attrs] = ["aspect_mongo_id", "post_mongo_id"]

    generic_json_to_two_csvs(model_hash) do |hash|
      main_row = [hash["_id"], hash["name"], hash["created_at"], hash["updated_at"]]
      post_visibility_rows = hash["post_ids"].map{|id| [hash["_id"],id]}
      [main_row, post_visibility_rows]
    end
  end
  def generic_json_to_two_csvs model_hash
    debug "Converting #{model_hash[:name]} json to two csvs"
    json_file = File.open(model_hash[:json_file])

    main_csv = CSV.open("#{dirpath}/csv/#{model_hash[:name]}.csv",'w')
    main_csv << model_hash[:main_attrs]

    join_csv = CSV.open("#{dirpath}/csv/#{model_hash[:join_table_name]}.csv",'w')
    join_csv << model_hash[:join_table_attrs]

    json_file.each do |aspect_json|
      hash = JSON.parse(aspect_json)
      result = yield(hash)
      main_csv << result.first
      result.last.each{|row| join_csv << row}
    end
    json_file.close
    main_csv.close
    join_csv.close
  end
end
