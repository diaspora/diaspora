require 'active_record'

Resque.after_fork do |job|
  ActiveRecord::Base.connection_handler.verify_active_connections!
end
