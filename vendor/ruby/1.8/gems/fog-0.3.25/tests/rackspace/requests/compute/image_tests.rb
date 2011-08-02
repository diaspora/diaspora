Shindo.tests('Rackspace::Compute | image requests', ['rackspace']) do

  @images_format = {
    'id'        => Integer,
    'name'      => String,
    'status'    => String,
    'updated'   => String,
  }

  @image_format = @images_format.merge({
    'created'  => String,
    'progress' => Integer,
  })

  tests('success') do

    @server = Rackspace[:compute].servers.create(:flavor_id => 1, :image_id => 19, :name => 'foggetserverdetails')
    @server.wait_for { ready? }
    @image_id = nil

    tests("#create_image(#{@server.id})").formats(@images_format.merge('serverId' => Integer)) do
      data = Rackspace[:compute].create_image(@server.id).body['image']
      @image_id = data['id']
      data
    end

    unless Fog.mocking?
      Rackspace[:compute].images.get(@image_id).wait_for { ready? }
    end

    tests("#get_image_details(#{@image_id})").formats(@image_format) do
      pending if Fog.mocking?
      Rackspace[:compute].get_image_details(@image_id).body['image']
    end

    tests('#list_images').formats({'images' => [Rackspace::Compute::Formats::SUMMARY]}) do
      Rackspace[:compute].list_images.body
    end

    tests('#list_images_detail').formats({'images' => [@images_format]}) do
      Rackspace[:compute].list_images_detail.body
    end

    unless Fog.mocking?
      Rackspace[:compute].images.get(@image_id).wait_for { ready? }
    end

    tests("#delete_image(#{@image_id})").succeeds do
      pending if Fog.mocking? # because it will fail without the wait just above here, which won't work
      Rackspace[:compute].delete_image(@image_id)
    end

    @server.destroy

  end

  tests('failure') do

    tests('#delete_image(0)').raises(Excon::Errors::BadRequest) do
      Rackspace[:compute].delete_image(0)
    end

    tests('#get_image_details(0)').raises(Fog::Rackspace::Compute::NotFound) do
      pending if Fog.mocking?
      Rackspace[:compute].get_image_details(0)
    end

  end

end
