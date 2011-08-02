Shindo.tests('Slicehost::Compute | image requests', ['slicehost']) do

  @image_format = {
    'id'    => Integer,
    'name'  => String
  }

  tests('success') do

    tests('#get_image(19)').formats(@image_format) do
      pending if Fog.mocking?
      Slicehost[:compute].get_image(19).body
    end

    tests('#get_images').formats({ 'images' => [@image_format] }) do
      pending if Fog.mocking?
      Slicehost[:compute].get_images.body
    end

  end

  tests('failure') do

    tests('#get_image(0)').raises(Excon::Errors::Forbidden) do
      pending if Fog.mocking?
      Slicehost[:compute].get_image(0)
    end

  end

end
