require 'spec_helper' 

describe 'dispatching' do
  before do
    pending "TEST POLUTION HERE :("
     @luke, @leia, @raph = set_up_friends
  end
  
  context "lukes' comment on luke's public post gets retracted" do
   it 'should not trigger a public dispatch' do
    #luke has a public post and comments on it
     p = Factory(:status_message, :public => true, :author => @luke.person)
     c = @luke.comment("awesomesauseum", :post => p)


     Postzord::Dispatcher::Public.should_not_receive(:new)
     Postzord::Dispatcher::Private.should_receive(:new).and_return(stub(:post => true))
     #luke now retracts his comment
      fantasy_resque do
        @luke.retract(c)
      end 
   end
  end
  
end
