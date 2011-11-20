require 'spec_helper' 

describe "Dispatching" do
  context "a comment retraction on a public post" do
    it "should trigger a private dispatch" do
      luke, leia, raph = set_up_friends

      # Luke has a public post and comments on it
      p = Factory(:status_message, :public => true, :author => luke.person)
      c = luke.comment("awesomesauseum", :post => p)

      # Luke now retracts his comment
      Postzord::Dispatcher::Public.should_not_receive(:new)
      Postzord::Dispatcher::Private.should_receive(:new).and_return(stub(:post => true))
      fantasy_resque do
        luke.retract(c)
      end 
    end
  end
end
