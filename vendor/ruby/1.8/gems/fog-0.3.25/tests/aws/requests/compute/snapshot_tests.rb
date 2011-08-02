Shindo.tests('AWS::Compute | snapshot requests', ['aws']) do

  @snapshot_format = {
    'description' => NilClass,
    'ownerId'     => String,
    'progress'    => String,
    'snapshotId'  => String,
    'startTime'   => Time,
    'status'      => String,
    'volumeId'    => String,
    'volumeSize'  => Integer
  }

  @snapshots_format = {
    'requestId'   => String,
    'snapshotSet' => [@snapshot_format.merge('tagSet' => {})]
  }

  @volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1)

  tests('success') do

    @snapshot_id = nil

    tests("#create_snapshot(#{@volume.identity})").formats(@snapshot_format.merge('progress' => NilClass, 'requestId' => String)) do
      data = AWS[:compute].create_snapshot(@volume.identity).body
      @snapshot_id = data['snapshotId']
      data
    end

    Fog.wait_for { AWS[:compute].snapshots.get(@snapshot_id) }
    AWS[:compute].snapshots.get(@snapshot_id).wait_for { ready? }

    tests("#describe_snapshots").formats(@snapshots_format) do
      AWS[:compute].describe_snapshots.body
    end

    tests("#describe_snapshots('snapshot-id' => '#{@snapshot_id}')").formats(@snapshots_format) do
      AWS[:compute].describe_snapshots('snapshot-id' => @snapshot_id).body
    end

    tests("#delete_snapshots(#{@snapshot_id})").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].delete_snapshot(@snapshot_id).body
    end

  end
  tests ('failure') do

    tests("#delete_snapshot('snap-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].delete_snapshot('snap-00000000')
    end

  end

  @volume.destroy

end
