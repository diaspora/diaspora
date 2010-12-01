require 'will_paginate/deprecation'

# = You *will* paginate!
#
# First read about WillPaginate::Finders::Base, then see
# WillPaginate::ViewHelpers. The magical array you're handling in-between is
# WillPaginate::Collection.
#
# Happy paginating!
module WillPaginate
end

if defined?(::Rails::Railtie)
  require 'will_paginate/railtie'
end

if defined?(::Merb::Plugins)
  require 'will_paginate/view_helpers/merb'
  # auto-load the right ORM adapter
  if adapter = { :datamapper => 'data_mapper', :activerecord => 'active_record', :sequel => 'sequel' }[Merb.orm]
    require "will_paginate/finders/#{adapter}"
  end
end
