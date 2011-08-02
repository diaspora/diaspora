require 'spec_helper'

describe "An RSpec Mock" do
  it "hides internals in its inspect representation" do
    m = double('cup')
    m.inspect.should =~ /#<RSpec::Mocks::Mock:0x[a-f0-9.]+ @name="cup">/
  end
end
