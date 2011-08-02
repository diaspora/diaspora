Shindo.tests('Slicehost::Compute | flavor requests', ['slicehost']) do

  @flavor_format = {
    'id'    => Integer,
    'name'  => String,
    'price' => Integer,
    'ram'   => Integer
  }

  tests('success') do

    tests('#get_flavor(1)').formats(@flavor_format) do
      pending if Fog.mocking?
      Slicehost[:compute].get_flavor(1).body
    end

    tests('#get_flavors').formats({ 'flavors' => [@flavor_format] }) do
      pending if Fog.mocking?
      Slicehost[:compute].get_flavors.body
    end

  end

  tests('failure') do

    tests('#get_flavor(0)').raises(Excon::Errors::Forbidden) do
      pending if Fog.mocking?
      Slicehost[:compute].get_flavor(0)
    end

  end

end
