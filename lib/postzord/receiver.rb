#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require File.join(Rails.root, 'lib/webfinger')
require File.join(Rails.root, 'lib/diaspora/parser')

module Postzord
  class Receiver

    def initialize(user, salmon_xml)
      @user = user
      @salmon = Salmon::SalmonSlap.parse(salmon_xml, @user)
      @salmon_author = Webfinger.new(@salmon.author_email).fetch
    end

    def perform
      if @salmon_author && @salmon.verified_for_key?(@salmon_author.public_key)
        @object = Diaspora::Parser.from_xml(@salmon.parsed_data)
        @object.receive
      else
        Rails.logger.info("event=receive status=abort recipient=#{@user.diaspora_handle} sender=#{@salmon.author_email} reason='not_verified for key'")
        nil
      end
    end

    protected
  end
end
