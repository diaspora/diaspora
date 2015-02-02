# Stdlib
require 'cgi'
require 'uri'

# Not auto required gems
require 'builder/xchar'
require 'carrierwave/orm/activerecord'
require 'erb'
require 'redcarpet/render_strip'
require 'typhoeus'

# Presenters
require 'post_presenter'

# Our libs
require 'collect_user_photos'
require 'diaspora'
require 'direction_detector'
require 'email_inviter'
require 'evil_query'
require 'federation_logger'
require 'hydra_wrapper'
require 'postzord'
require 'publisher'
require 'pubsubhubbub'
require 'statistics'
require 'stream'
require 'account_deleter'

# diaspora-foundation adapters
require 'diaspora_federation.rb'
require 'adapters/salmon.rb'
require 'adapters/hcard.rb'
require 'adapters/webfinger.rb'
