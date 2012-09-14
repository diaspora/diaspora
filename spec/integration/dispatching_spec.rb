require 'spec_helper' 

describe "Dispatching" do
  context "a comment retraction on a public post" do
    it "should trigger a private dispatch" do
      luke, leia, raph = set_up_friends
      # Luke has a public post and comments on it
      post = FactoryGirl.create(:status_message, :public => true, :author => luke.person)

      fantasy_resque do
        comment = luke.comment!(post, "awesomesauseum")
        # Luke now retracts his comment
        Postzord::Dispatcher::Public.should_not_receive(:new)
        Postzord::Dispatcher::Private.should_receive(:new).and_return(stub(:post => true))
        luke.retract(comment)
      end 
    end
  end
end
