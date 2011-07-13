require 'spec_helper'

describe Reshare do
  it 'has a valid Factory' do
    Factory(:reshare).should be_valid
  end

  it 'requires root' do
    reshare = Factory.build(:reshare, :root => nil)
    reshare.should_not be_valid
  end

  it 'require public root' do
    Factory.build(:reshare, :root => Factory.build(:status_message, :public => false)).should_not be_valid
  end

  it 'forces public' do
    Factory(:reshare, :public => false).public.should be_true
  end

  describe "#receive" do
    before do
      @reshare = Factory.build(:reshare, :root => Factory.build(:status_message, :public => false))
      @root = @reshare.root
      @reshare.receive(@root.author.owner, @reshare.author)
    end

    it 'increments the reshare count' do
      @root.resharers.count.should == 1
    end

    it 'adds the resharer to the re-sharers of the post' do
      @root.resharers.should include(@reshare.author)
    end
  end
end
