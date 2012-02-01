require 'spec_helper'

describe EvilQuery::Participation do
  before do
    @status_message = Factory(:status_message, :author => bob.person)
  end

  it "includes posts liked by the user" do
    Factory(:like, :target => @status_message, :author => alice.person)
    EvilQuery::Participation.new(alice).posts.should include(@status_message)
  end

  it "includes posts commented by the user" do
    alice.comment!(@status_message, "hey")
    EvilQuery::Participation.new(alice).posts.should include(@status_message)
  end
end