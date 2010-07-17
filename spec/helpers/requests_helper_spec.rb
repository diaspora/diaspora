require File.dirname(__FILE__) + '/../spec_helper'

include RequestsHelper

describe RequestsHelper do
  describe "profile" do
    it 'should fetch the public webfinger profile on request' do
      #post :create {:request => {:destination_url => 'tom@tom.joindiaspora.com'}
     
      url = diaspora_url('http://tom.joindiaspora.com/')
      url.should == 'http://tom.joindiaspora.com/'


      url = diaspora_url('tom@tom.joindiaspora.com')
      url.should == 'http://tom.joindiaspora.com/'
    end
  end
end
