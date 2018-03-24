# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service < ApplicationRecord
  attr_accessor :provider, :info, :access_level

  belongs_to :user
  validates_uniqueness_of :uid, :scope => :type

  def profile_photo_url
    nil
  end

  def post_opts(post)
    # don't do anything (should be overridden by service extensions)
  end

  class << self

    def titles(service_strings)
      service_strings.map {|s| "Services::#{s.titleize}"}
    end

    def first_from_omniauth( auth_hash )
      @@auth = auth_hash
      find_by(type: service_type, uid: options[:uid])
    end

    def initialize_from_omniauth( auth_hash )
      @@auth = auth_hash
      service_type.constantize.new( options )
    end

    def auth
      @@auth
    end

    def service_type
      "Services::#{options[:provider].camelize}"
    end

    def options
      {
        nickname:      auth['info']['nickname'],
        access_token:  auth['credentials']['token'],
        access_secret: auth['credentials']['secret'],
        uid:           auth['uid'],
        provider:      auth['provider'],
        info:          auth['info']
      }
    end

    private :auth, :service_type, :options
  end
end
