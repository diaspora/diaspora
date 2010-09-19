#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

if ENV['MONGOHQ_URL']	
  MongoMapper.config = {Rails.env => {'uri' => ENV['MONGOHQ_URL']}}
  MongoMapper.connect(Rails.env)
  Magent.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
else
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "diaspora-#{Rails.env}"	
end

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect_to_master if forked
   end
end

