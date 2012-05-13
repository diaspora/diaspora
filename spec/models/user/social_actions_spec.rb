require "spec_helper"

describe User::SocialActions do
  before do
    @bobs_aspect = bob.aspects.where(:name => "generic").first
    @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
  end

  describe 'User#comment!' do
    it "sets the comment text" do
      alice.comment!(@status, "unicorn_mountain").text.should == "unicorn_mountain"
    end

    it "creates a partcipation" do
      lambda{ alice.comment!(@status, "bro") }.should change(Participation, :count).by(1)
      alice.participations.last.target.should == @status
    end

    it "creates the like" do
      lambda{ alice.comment!(@status, "bro") }.should change(Comment, :count).by(1)
    end

    it "federates" do
      Participation::Generator.any_instance.stub(:create!)
      Postzord::Dispatcher.should_receive(:defer_build_and_post)
      alice.comment!(@status, "omg")
    end
  end

  describe 'User#like!' do
    it "creates a partcipation" do
      lambda{ alice.like!(@status) }.should change(Participation, :count).by(1)
      alice.participations.last.target.should == @status
    end

    it "creates the like" do
      lambda{ alice.like!(@status) }.should change(Like, :count).by(1)
    end

    it "federates" do
      #participation and like
      Participation::Generator.any_instance.stub(:create!)
      Postzord::Dispatcher.should_receive(:defer_build_and_post)
      alice.like!(@status)
    end
  end

  describe 'User#like!' do
    before do
      @bobs_aspect = bob.aspects.where(:name => "generic").first
      @status = bob.post(:status_message, :text => "hello", :to => @bobs_aspect.id)
    end

    it "creates a partcipation" do
      lambda{ alice.like!(@status) }.should change(Participation, :count).by(1)
    end

    it "creates the like" do
      lambda{ alice.like!(@status) }.should change(Like, :count).by(1)
    end

    it "federates" do
      #participation and like
      Postzord::Dispatcher.should_receive(:defer_build_and_post).twice
      alice.like!(@status)
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
      likes = @status.likes
      expect { alice.like!(@status) }.to raise_error

      @status.reload.likes.should == likes
    end
  end
end