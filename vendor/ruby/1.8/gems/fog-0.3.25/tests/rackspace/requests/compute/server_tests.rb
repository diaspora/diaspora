Shindo.tests('Rackspace::Compute | server requests', ['rackspace']) do

  @server_format = {
    'addresses' => {
      'private' => [String],
      'public'  => [String]
    },
    'flavorId'  => Integer,
    'hostId'    => String,
    'id'        => Integer,
    'imageId'   => Integer,
    'metadata'  => {},
    'name'      => String,
    'progress'  => Integer,
    'status'    => String
  }

  tests('success') do

    @server_id = nil

    tests('#create_server(1, 19)').formats(@server_format.merge('adminPass' => String)) do
      # 1 => 256MB, 19 => Gentoo
      data = Rackspace[:compute].create_server(1, 19).body['server']
      @server_id = data['id']
      data
    end

    Rackspace[:compute].servers.get(@server_id).wait_for { ready? }

    tests("#get_server_details(#{@server_id})").formats(@server_format) do
      Rackspace[:compute].get_server_details(@server_id).body['server']
    end

    tests('#list_servers').formats({'servers' => [Rackspace::Compute::Formats::SUMMARY]}) do
      Rackspace[:compute].list_servers.body
    end

    tests('#list_servers_detail').formats({'servers' => [@server_format]}) do
      Rackspace[:compute].list_servers_detail.body
    end

    Rackspace[:compute].servers.get(@server_id).wait_for { ready? }

    tests("#update_server(#{@server_id}, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')").succeeds do
      Rackspace[:compute].update_server(@server_id, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')
    end

    Rackspace[:compute].servers.get(@server_id).wait_for { ready? }

    tests("#reboot_server(#{@server_id}, 'HARD')").succeeds do
      pending if Fog.mocking?
      Rackspace[:compute].reboot_server(@server_id, 'HARD')
    end

    Rackspace[:compute].servers.get(@server_id).wait_for { ready? }

    tests("#reboot_server(#{@server_id}, 'SOFT')").succeeds do
      pending if Fog.mocking?
      Rackspace[:compute].reboot_server(@server_id, 'SOFT')
    end

    Rackspace[:compute].servers.get(@server_id).wait_for { ready? }

    tests("#delete_server(#{@server_id})").succeeds do
      Rackspace[:compute].delete_server(@server_id)
    end

  end

  tests('failure') do

    tests('#delete_server(0)').raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].delete_server(0)
    end

    tests('#get_server_details(0)').raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].get_server_details(0)
    end

    tests("#update_server(0, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')").raises(Fog::Rackspace::Compute::NotFound) do
      Rackspace[:compute].update_server(0, :name => 'fogupdatedserver', :adminPass => 'fogupdatedserver')
    end

    tests('#reboot_server(0)').raises(Fog::Rackspace::Compute::NotFound) do
      pending if Fog.mocking?
      Rackspace[:compute].reboot_server(0)
    end

  end

end
