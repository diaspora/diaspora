#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

ENV['MONGODB_URL'] = ENV['MONGOHQ_URL'] || URI::Generic.build(:scheme => 'mongodb', :host => AppConfig[:mongo_host], :port => AppConfig[:mongo_port], :path => "/diaspora-#{Rails.env}").to_s

MongoMapper.config = {::Rails.env => {'uri' => ENV['MONGODB_URL']}}
MongoMapper.connect ::Rails.env

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end

$stderr.puts "Security Warning (11/29/2010):  if you are using Diaspora on the internet, please make sure your mongodb is started with '--bind 127.0.0.1' or you are using a database password"
