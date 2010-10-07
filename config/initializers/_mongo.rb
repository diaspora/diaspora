#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

ENV['MONGODB_URL'] = ENV['MONGOHQ_URL'] || URI::Generic.build(:scheme => 'mongodb', :host => APP_CONFIG['mongo_host'], :port => APP_CONFIG['mongo_port'], :path => "/diaspora-#{Rails.env}").to_s

MongoMapper.config = {RAILS_ENV => {'uri' => ENV['MONGODB_URL']}}
MongoMapper.connect RAILS_ENV

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect_to_master if forked
   end
end

Magent.connection = MongoMapper.connection
