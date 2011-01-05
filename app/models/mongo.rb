module Mongo
  def self.table_name_prefix
    "mongo_"
  end

  class User < ActiveRecord::Base; end
end