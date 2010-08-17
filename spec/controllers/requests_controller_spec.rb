require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper 
include RequestsHelper 
describe RequestsController do
    before do 
    @tom = Redfinger.finger('tom@tom.joindiaspora.com')
    @evan = Redfinger.finger('evan@status.net')
    @max = Redfinger.finger('mbs348@gmail.com')
  end
    it 'should return the correct tag and url for a given address' do
      relationship_flow('tom@tom.joindiaspora.com')[:friend].include?("receive/user").should ==  true
    end


end
