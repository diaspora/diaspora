# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  class Exporter
    SERIALIZED_VERSION = "2.0"

    def initialize(user)
      @user = user
    end

    def execute
      JSON.generate full_archive
    end

    private

    def full_archive
      {version: SERIALIZED_VERSION}
        .merge(Export::UserSerializer.new(@user.id).as_json)
        .merge(Export::OthersDataSerializer.new(@user.id).as_json)
    end
  end
end
