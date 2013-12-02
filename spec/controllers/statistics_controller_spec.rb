#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatisticsController do

  describe '#statistics' do
    
    it 'responds to format json' do
      get :statistics, :format => 'json'
      response.code.should == '200'
    end
    
    it 'contains json' do
      get :statistics, :format => 'json'
      json = JSON.parse(response.body)
      json['name'].should be_present
    end
  end

end
