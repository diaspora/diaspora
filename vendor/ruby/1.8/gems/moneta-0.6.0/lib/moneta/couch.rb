begin
  require "couchrest"
rescue LoadError
  puts "You need the couchrest gem to use the CouchDB store"
  exit
end

module Moneta
  class Couch
    include Defaults
    
    def initialize(options = {})
      @db = ::CouchRest.database!(options[:db])
      unless options[:skip_expires]
        @expiration = Moneta::Couch.new(:db => "#{options[:db]}_expiration", :skip_expires => true)
        self.extend(StringExpires)
      end
    end

    def key?(key)
      !self[key].nil?
    rescue RestClient::ResourceNotFound
      false
    end

    alias has_key? key?

    def [](key)
      @db.get(key)["data"]
    rescue RestClient::ResourceNotFound
      nil
    end

    def []=(key, value)
      @db.save_doc("_id" => key, :data => value)
    rescue RestClient::RequestFailed
      self[key]
    end

    def delete(key)
      value = @db.get(key)
      @db.delete_doc({"_id" => value["_id"], "_rev" => value["_rev"]}) if value
      value["data"]
    rescue RestClient::ResourceNotFound
      nil
    end

    def update_key(key, options = {})
      val = self[key]
      self.store(key, val, options)
    rescue RestClient::ResourceNotFound
      nil
    end

    def clear
      @db.recreate!
    end

    def delete_store
      @db.delete!
    end
  end
end
