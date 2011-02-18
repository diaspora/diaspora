# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'json'
require 'csv'
require File.join(Rails.root, 'lib/data_conversion/base')

module DataConversion
  class ExportFromMongo < DataConversion::Base
    def csv_options
      {:col_sep => ",",
       :row_sep => :auto,
       :quote_char => '"',
       :field_size_limit => nil,
       :converters => nil,
       :unconverted_fields => nil,
       :headers => false,
       :return_headers => false,
       :header_converters => nil,
       :skip_blanks => false,
       :force_quotes => false}
    end

    def clear_dir
      ["#{full_path}/json", "#{full_path}/csv"].each do |path|
        FileUtils.rm_rf(path)
        FileUtils.mkdir_p(path)
      end
    end

    def db_name
      "diaspora-#{Rails.env}"
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
      log "Starting JSON export..."
      models.each do |model|
        log "Starting #{model[:name]} JSON export..."
        filename ="#{full_path}/json/#{model[:name]}.json"
        model[:json_file] = filename
        `#{json_for_model(model[:name])} > #{filename}`
        log "Completed #{model[:name]} JSON export to #{directory}/json/#{model[:name]}.json."
      end
      log "JSON export complete."
    end

    def convert_json_files
      models.each do |model|
        self.send("#{model[:name]}_json_to_csv".to_sym, model)
      end
    end

    def generic_json_to_csv model_hash
      log "Converting #{model_hash[:name]} json to csv"
      json_file = File.open(model_hash[:json_file])

      csv = CSV.open("#{full_path}/csv/#{model_hash[:name]}.csv", 'w')
      csv << model_hash[:attrs]

      json_file.each do |aspect_json|
        hash = JSON.parse(aspect_json)
        csv << yield(hash)
      end
      json_file.close
      csv.close
    end

    def comments_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name|
          attr_val = hash[attr_name]
          if (attr_name == "youtube_titles" && attr_val && !attr_val.empty?)
            attr_val.to_yaml
          else
            attr_val
          end
        }
      end
    end

    def contacts_json_to_csv model_hash
      generic_json_to_two_csvs(model_hash) do |hash|
        main_row = model_hash[:main_mongo_attrs].map { |attr_name| hash[attr_name] }
        if hash["aspect_ids"]
          aspect_membership_rows = hash["aspect_ids"].map { |id| [hash["_id"], id] }
        else
          aspect_membership_rows = []
        end
        [main_row, aspect_membership_rows]
      end
      #Also writes the aspect memberships csv
    end

    def invitations_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }
      end
    end

    def notifications_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }
      end
    end
    def services_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }
      end
    end
    def people_json_to_csv model_hash
      #Also writes the profiles csv

      log "Converting #{model_hash[:name]} json to csv"
      json_file = File.open(model_hash[:json_file])

      people_csv = CSV.open("#{full_path}/csv/#{model_hash[:name]}.csv", 'w')
      people_csv << model_hash[:attrs]

      profiles_csv = CSV.open("#{full_path}/csv/profiles.csv", 'w')
      profiles_csv << model_hash[:profile_attrs]

      json_file.each do |aspect_json|
        hash = JSON.parse(aspect_json)
        person_row = model_hash[:attrs].map do |attr_name|
          attr_name = attr_name.gsub("mongo_", "")
          attr_name = "_id" if attr_name == "id"
          hash[attr_name]
        end
        people_csv << person_row

        profile_row = model_hash[:profile_attrs].map do |attr_name|
          if attr_name == "person_mongo_id"
            hash["_id"] #set person_mongo_id to the person id
          else
            hash["profile"][attr_name]
          end
        end
        profiles_csv << profile_row
      end
      json_file.close
      people_csv.close
      profiles_csv.close
    end

    def posts_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name|
          attr_val = hash[attr_name]
          if (attr_name == "youtube_titles" && attr_val && !attr_val.empty?)
            attr_val.to_yaml
          else
            attr_val
          end
        }
      end
      #has to handle the polymorphic stuff
    end

    def requests_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }
      end
    end

    def users_json_to_csv model_hash
      generic_json_to_csv(model_hash) do |hash|
        model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }
      end
    end

    def aspects_json_to_csv model_hash
      log "Converting aspects json to aspects and post_visibilities csvs"

      generic_json_to_two_csvs(model_hash) do |hash|
        main_row = model_hash[:mongo_attrs].map { |attr_name| hash[attr_name] }

        if hash["post_ids"]
          post_visibility_rows = hash["post_ids"].map { |id| [hash["_id"], id] }
        else
          post_visibility_rows = []
        end

        [main_row, post_visibility_rows]
      end
    end

    def generic_json_to_two_csvs model_hash
      log "Converting #{model_hash[:name]} json to two csvs"
      json_file = File.open(model_hash[:json_file])

      main_csv = CSV.open("#{full_path}/csv/#{model_hash[:name]}.csv", 'w')
      main_csv << model_hash[:main_attrs]

      join_csv = CSV.open("#{full_path}/csv/#{model_hash[:join_table_name]}.csv", 'w')
      join_csv << model_hash[:join_table_attrs] unless model_hash[:join_table_attrs].empty?

      json_file.each do |aspect_json|
        hash = JSON.parse(aspect_json)
        result = yield(hash)
        main_csv << result.first
        result.last.each { |row| join_csv << row }
      end
      json_file.close
      main_csv.close
      join_csv.close
    end
  end
end
