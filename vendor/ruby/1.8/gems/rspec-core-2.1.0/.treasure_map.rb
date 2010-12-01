Beholder.runner = 'clear; ruby -Ilib -Ispec'

map_for(:rspec_core) do |m|

  m.watch 'lib', 'spec', 'example_specs'

  m.add_mapping %r%example_specs/(.*)_spec\.rb% do |match|
    ["example_specs/#{match[1]}_spec.rb"]
  end

  m.add_mapping %r%spec/(.*)_spec\.rb% do |match|
    ["spec/#{match[1]}_spec.rb"]
  end

  m.add_mapping %r%spec/spec_helper\.rb% do |match|
    Dir["spec/**/*_spec.rb"]
  end

  m.add_mapping %r%lib/(.*)\.rb% do |match|
    tests_matching match[1]
  end

end
