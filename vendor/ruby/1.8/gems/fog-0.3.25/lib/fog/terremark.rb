require 'nokogiri'
require 'fog/core/parser'

require 'fog/terremark/shared'
require 'fog/terremark/parser'
require 'fog/terremark/ecloud'
require 'fog/terremark/vcloud'

module Fog
  module Terremark
    ECLOUD_OPTIONS = [:terremark_ecloud_username, :terremark_ecloud_password]
    VCLOUD_OPTIONS = [:terremark_vcloud_username, :terremark_vcloud_password]
  end
end
