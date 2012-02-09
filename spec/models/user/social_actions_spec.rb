require "spec_helper"

describe User::SocialActions do
  describe 'User#like!' do
    before do
      @bobs_aspect = bob.aspects.where(:name => "generic").first
      @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
    end

    it "should be able to like on one's own status" do
      like = alice.like!(@status)
      @status.reload.likes.first.should == like
    end

    it "should be able to like on a contact's status" do
      like = bob.like!(@status)
      @status.reload.likes.first.should == like
    end

    it "does not allow multiple likes" do
      alice.like!(@status)
      lambda {
        alice.like!(@status)
      }.should_not change(@status, :likes)
    end
  end
end