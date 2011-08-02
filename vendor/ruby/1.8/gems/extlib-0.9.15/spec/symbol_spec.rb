require 'spec_helper'
require 'extlib/symbol'

describe Symbol, "#/" do
  it "concanates operands with File::SEPARATOR" do
    (:merb / "core").should == "merb#{File::SEPARATOR}core"
    (:merb / :core).should == "merb#{File::SEPARATOR}core"
  end
end
