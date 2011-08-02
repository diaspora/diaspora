Shindo.tests('Bluebox::Compute | template requests', ['bluebox']) do

  @template_format = {
    'created'     => String,
    'description' => String,
    'id'          => String,
    'public'      => Fog::Boolean
  }

  tests('success') do

    @template_id  = 'a00baa8f-b5d0-4815-8238-b471c4c4bf72' # Ubuntu 9.10 64bit

    tests("get_template('#{@template_id}')").formats(@template_format) do
      pending if Fog.mocking?
      Bluebox[:compute].get_template(@template_id).body
    end

    tests("get_templates").formats([@template_format]) do
      pending if Fog.mocking?
      Bluebox[:compute].get_templates.body
    end

  end

  tests('failure') do

    tests("get_template('00000000-0000-0000-0000-000000000000')").raises(Fog::Bluebox::Compute::NotFound) do
      pending if Fog.mocking?
      Bluebox[:compute].get_template('00000000-0000-0000-0000-000000000000')
    end

  end

end
