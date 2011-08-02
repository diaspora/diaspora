Shindo.tests('Rackspace::Storage | object requests', ['rackspace']) do

  unless Fog.mocking?
    @directory = Rackspace[:storage].directories.create(:key => 'fogobjecttests')
  end

  tests('success') do

    tests("#put_object('fogobjecttests', 'fog_object')").succeeds do
      pending if Fog.mocking?
      Rackspace[:storage].put_object('fogobjecttests', 'fog_object', lorem_file)
    end

    tests("#get_object('fogobjectests', 'fog_object')").succeeds do
      pending if Fog.mocking?
      Rackspace[:storage].get_object('fogobjecttests', 'fog_object')
    end

    tests("#head_object('fogobjectests', 'fog_object')").succeeds do
      pending if Fog.mocking?
      Rackspace[:storage].head_object('fogobjecttests', 'fog_object')
    end

    tests("#delete_object('fogobjecttests', 'fog_object')").succeeds do
      pending if Fog.mocking?
      Rackspace[:storage].delete_object('fogobjecttests', 'fog_object')
    end

  end

  tests('failure') do

    tests("#get_object('fogobjecttests', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].get_object('fogobjecttests', 'fog_non_object')
    end

    tests("#get_object('fognoncontainer', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].get_object('fognoncontainer', 'fog_non_object')
    end

    tests("#head_object('fogobjecttests', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].head_object('fogobjecttests', 'fog_non_object')
    end

    tests("#head_object('fognoncontainer', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].head_object('fognoncontainer', 'fog_non_object')
    end

    tests("#delete_object('fogobjecttests', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].delete_object('fogobjecttests', 'fog_non_object')
    end

    tests("#delete_object('fognoncontainer', 'fog_non_object')").raises(Fog::Rackspace::Storage::NotFound) do
      pending if Fog.mocking?
      Rackspace[:storage].delete_object('fognoncontainer', 'fog_non_object')
    end

  end

  unless Fog.mocking?
    @directory.destroy
  end

end