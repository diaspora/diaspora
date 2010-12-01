require 'spec_helper'

describe "extensions" do
  describe "debugger" do
    it "is defined on Kernel" do
      Kernel.should respond_to(:debugger)
    end
  end
end
