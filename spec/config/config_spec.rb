#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe 'making sure the config is parsed as should' do
  
  describe 'app config' do
    
    it 'pod_url has a trailing slash' do
      APP_CONFIG[:pod_url].should == 'http://example.org/'
    end
    
    it 'terse_pod_url is correctly parsed' do
      APP_CONFIG[:terse_pod_url].should == 'example.org'
    end
  
  end
   
end
