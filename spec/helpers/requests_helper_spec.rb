require File.dirname(__FILE__) + '/../spec_helper'

include RequestsHelper

describe RequestsHelper do

  before do 
    #@tom = Redfinger.finger('tom@tom.joindiaspora.com')
    #@evan = Redfinger.finger('evan@status.net')
    #@max = Redfinger.finger('mbs348@gmail.com')
  end


  describe "profile" do
    it 'should fetch the public webfinger profile on request' do
      pending 
      #post :create {:request => {:destination_url => 'tom@tom.joindiaspora.com'}
      url = diaspora_url('http://tom.joindiaspora.com/')
      url.should == 'http://tom.joindiaspora.com/'


      url = diaspora_url('tom@tom.joindiaspora.com')
      url.should == 'http://tom.joindiaspora.com/'
    end

    it 'should detect how to subscribe to a diaspora or ostatus webfinger profile' do
      pending
      subscription_mode(@tom).should == :friend
      subscription_mode(@evan).should == :subscribe
      subscription_mode(@max).should == :none
    end

    it 'should return the correct tag and url for a given address' do
      pending
      relationship_flow('tom@tom.joindiaspora.com')[:friend].should == 'http://tom.joindiaspora.com/'
      relationship_flow('evan@status.net')[:subscribe].should == 'http://evan.status.net/api/statuses/user_timeline/1.atom'
    end

  end

end
