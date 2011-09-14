#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe OAuth2::Provider::Models::ActiveRecord::Client do
  describe 'validations'do
    it 'validates uniqueness on identifier' do
      OAuth2::Provider::Models::ActiveRecord::Client.create(:oauth_identifier => "three")
      OAuth2::Provider::Models::ActiveRecord::Client.new(:oauth_identifier => "three").valid?.should be_false
    end
  end
end

