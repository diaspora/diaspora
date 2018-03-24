# frozen_string_literal: true

# Stdlib
require 'cgi'
require 'uri'

# Not auto required gems
require 'builder/xchar'
require 'carrierwave/orm/activerecord'
require 'erb'
require 'redcarpet/render_strip'
require 'typhoeus'

# Our libs
require 'diaspora'
require 'direction_detector'
require 'email_inviter'
require 'evil_query'
require 'publisher'
require 'pubsubhubbub'
require 'stream'
require 'account_deleter'
