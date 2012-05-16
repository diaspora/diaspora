#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe OAuth2::Provider::Models::ActiveRecord::Authorization do
  describe 'validations'do
    before do
      @client = FactoryGirl.create(:app)
    end

    it 'validates uniqueness on resource owner and client' do
      OAuth2::Provider::Models::ActiveRecord::Authorization.create!(:client => @client, :resource_owner => alice)
      OAuth2::Provider::Models::ActiveRecord::Authorization.new(:client => @client, :resource_owner => alice).should_not be_valid
    end

    it 'requires a resource owner for an authorization' do
      OAuth2::Provider::Models::ActiveRecord::Authorization.new(:client => @client).should_not be_valid
    end
  end
end

