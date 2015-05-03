require 'spec_helper' 

describe "Dispatching", :type => :request do
  context "a comment retraction on a public post" do
    it "should trigger a private dispatch" do
      luke, leia, raph = set_up_friends
      # Luke has a public post and comments on it
      post = FactoryGirl.create(:status_message, :public => true, :author => luke.person)

      comment = luke.comment!(post, "awesomesauseum")
      
      inlined_jobs do
        # Luke now retracts his comment
        expect(Postzord::Dispatcher::Public).not_to receive(:new)
        expect(Postzord::Dispatcher::Private).to receive(:new).and_return(double(:post => true))
        luke.retract(comment)
      end
    end
  end
end
