Shindo.tests('Rackspace::Compute | address requests', ['rackspace']) do

  tests('success') do

    @server = Rackspace[:compute].servers.create(:flavor_id => 1, :image_id => 19, :name => 'foglistaddresses')

    tests("#list_addresses(#{@server.id})").formats({'addresses' => {'private' => [String], 'public' => [String]}}) do
      Rackspace[:compute].list_addresses(@server.id).body
    end

    tests("#list_private_addresses(#{@server.id})").formats({'private' => [String]}) do
      Rackspace[:compute].list_private_addresses(@server.id).body
    end

    tests("#list_public_addresses(#{@server.id})").formats({'public' => [String]}) do
      Rackspace[:compute].list_public_addresses(@server.id).body
    end

    @server.wait_for { ready? }
    @server.destroy

  end

  tests('failure') do

    tests('#list_addresses(0)').raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].list_addresses(0)
    end

    tests('#list_private_addresses(0)').raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].list_private_addresses(0)
    end

    tests('#list_public_addresses(0)').raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].list_public_addresses(0)
    end

  end

end
