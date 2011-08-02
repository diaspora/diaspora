require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'Fog::AWS::Compute::Snapshot' do

  before(:all) do
    @volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1, :device => 'dev/sdz1')
    @volume.wait_for { ready? }
  end

  after(:all) do
    @volume.destroy
  end

  after(:each) do
    if @snapshot && !@snapshot.new_record?
      @snapshot.wait_for { ready? }
      @snapshot.destroy
    end
  end

  describe "#initialize" do

    it "should remap attributes from parser" do
      snapshot = AWS[:compute].snapshots.new(
        'snapshotId'  => 'snap-00000000',
        'startTime'   => 'now',
        'volumeId'    => 'vol-00000000',
        'description' => 'taken for safety'
      )
      snapshot.id.should == 'snap-00000000'
      snapshot.created_at.should == 'now'
      snapshot.volume_id.should == 'vol-00000000'
      snapshot.description.should == 'taken for safety'
    end

  end

  describe "#destroy" do

    it "should return true if the snapshot is deleted" do
      @snapshot = @volume.snapshots.create
      @snapshot.wait_for { ready? }
      @snapshot.destroy.should be_true
      @snapshot = nil # avoid the after(:each) block
    end

  end

  describe "#reload" do

    before(:each) do
      @snapshot = @volume.snapshots.create
      @reloaded = @snapshot.reload
    end

    it "should match the original" do
      @reloaded.should be_a(Fog::AWS::Compute::Snapshot)
      @reloaded.attributes.should == @snapshot.attributes
    end

  end

  describe "#save" do

    it "should persist the snapshot" do
      @snapshot = @volume.snapshots.new
      AWS[:compute].snapshots.get(@snapshot.id).should be_nil
      @snapshot.save.should be_true
      AWS[:compute].snapshots.get(@snapshot.id).should_not be_nil
    end

    it "should allow a description" do
      @snapshot = @volume.snapshots.create(:description => 'taken for safety')
      AWS[:compute].snapshots.get(@snapshot.id).description.should == 'taken for safety'
    end

  end

end
