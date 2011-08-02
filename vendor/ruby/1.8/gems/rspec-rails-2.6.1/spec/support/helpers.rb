module Helpers
  def stub_metadata(additional_metadata)
    stub_metadata = metadata_with(additional_metadata)
    RSpec::Core::ExampleGroup.stub(:metadata) { stub_metadata }
  end

  def metadata_with(additional_metadata)
    m = RSpec::Core::Metadata.new
    m.process("example group")

    group_metadata = additional_metadata.delete(:example_group)
    if group_metadata
      m[:example_group].merge!(group_metadata)
    end
    m.merge!(additional_metadata)
    m
  end

  RSpec.configure {|c| c.include self}
end
