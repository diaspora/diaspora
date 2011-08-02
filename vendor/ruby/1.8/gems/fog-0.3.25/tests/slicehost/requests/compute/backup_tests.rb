Shindo.tests('Slicehost::Compute | backup requests', ['slicehost']) do

  @backup_format = {
    'date'      => String,
    'id'        => Integer,
    'name'      => String,
    'slice-id'  => Integer
  }

  tests('success') do

    tests('#get_backups').formats({ 'backups' => [@backup_format] }) do
      pending if Fog.mocking?
      Slicehost[:compute].get_backups.body
    end

  end
end
