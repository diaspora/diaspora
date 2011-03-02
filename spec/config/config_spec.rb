#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
describe 'making sure the config is parsed as should' do

  describe 'pod_url' do
    it 'should have a trailing slash' do
      AppConfig[:pod_url].should == 'http://example.org/'
    end
  end

  describe 'terse_pod_url'
    it 'should be correctly parsed' do
      AppConfig[:pod_uri].host.should == 'example.org'
    end
end
