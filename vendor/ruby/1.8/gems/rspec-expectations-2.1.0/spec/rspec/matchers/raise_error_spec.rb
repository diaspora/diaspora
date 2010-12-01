require 'spec_helper'

describe "should raise_error" do
  it "passes if anything is raised" do
    lambda {raise}.should raise_error
  end
  
  it "fails if nothing is raised" do
    lambda {
      lambda {}.should raise_error
    }.should fail_with("expected Exception but nothing was raised")
  end
end

describe "raise_exception aliased to raise_error" do
  it "passes if anything is raised" do
    lambda {raise}.should raise_exception
  end
end

describe "should raise_error {|err| ... }" do
  it "passes if there is an error" do
    ran = false
    lambda { non_existent_method }.should raise_error {|e|
      ran = true
    }
    ran.should be_true
  end

  it "passes the error to the block" do
    error = nil
    lambda { non_existent_method }.should raise_error {|e|
      error = e
    }
    error.should be_kind_of(NameError)
  end
end

describe "should_not raise_error" do
  it "passes if nothing is raised" do
    lambda {}.should_not raise_error
  end
  
  it "fails if anything is raised" do
    lambda {
      lambda {raise}.should_not raise_error
    }.should fail_with("expected no Exception, got RuntimeError")
  end
end

describe "should raise_error(message)" do
  it "passes if RuntimeError is raised with the right message" do
    lambda {raise 'blah'}.should raise_error('blah')
  end
  it "passes if RuntimeError is raised with a matching message" do
    lambda {raise 'blah'}.should raise_error(/blah/)
  end
  it "passes if any other error is raised with the right message" do
    lambda {raise NameError.new('blah')}.should raise_error('blah')
  end
  it "fails if RuntimeError error is raised with the wrong message" do
    lambda do
      lambda {raise 'blarg'}.should raise_error('blah')
    end.should fail_with("expected Exception with \"blah\", got #<RuntimeError: blarg>")
  end
  it "fails if any other error is raised with the wrong message" do
    lambda do
      lambda {raise NameError.new('blarg')}.should raise_error('blah')
    end.should fail_with("expected Exception with \"blah\", got #<NameError: blarg>")
  end
end

describe "should_not raise_error(message)" do
  it "passes if RuntimeError error is raised with the different message" do
    lambda {raise 'blarg'}.should_not raise_error('blah')
  end
  it "passes if any other error is raised with the wrong message" do
    lambda {raise NameError.new('blarg')}.should_not raise_error('blah')
  end
  it "fails if RuntimeError is raised with message" do
    lambda do
      lambda {raise 'blah'}.should_not raise_error('blah')
    end.should fail_with(%Q|expected no Exception with "blah", got #<RuntimeError: blah>|)
  end
  it "fails if any other error is raised with message" do
    lambda do
      lambda {raise NameError.new('blah')}.should_not raise_error('blah')
    end.should fail_with(%Q|expected no Exception with "blah", got #<NameError: blah>|)
  end
end

describe "should raise_error(NamedError)" do
  it "passes if named error is raised" do
    lambda { non_existent_method }.should raise_error(NameError)
  end
  
  it "fails if nothing is raised" do
    lambda {
      lambda { }.should raise_error(NameError)
    }.should fail_with("expected NameError but nothing was raised")
  end
  
  it "fails if another error is raised (NameError)" do
    lambda {
      lambda { raise }.should raise_error(NameError)
    }.should fail_with("expected NameError, got RuntimeError")
  end
  
  it "fails if another error is raised (NameError)" do
    lambda {
      lambda { load "non/existent/file" }.should raise_error(NameError)
    }.should fail_with(/expected NameError, got #<LoadError/)
  end
end

describe "should_not raise_error(NamedError)" do
  it "passes if nothing is raised" do
    lambda { }.should_not raise_error(NameError)
  end
  
  it "passes if another error is raised" do
    lambda { raise }.should_not raise_error(NameError)
  end
  
  it "fails if named error is raised" do
    lambda {
      lambda { 1 + 'b' }.should_not raise_error(TypeError)
    }.should fail_with(/expected no TypeError, got #<TypeError: String can't be/)
  end  
end

describe "should raise_error(NamedError, error_message) with String" do
  it "passes if named error is raised with same message" do
    lambda { raise "example message" }.should raise_error(RuntimeError, "example message")
  end
  
  it "fails if nothing is raised" do
    lambda {
      lambda {}.should raise_error(RuntimeError, "example message")
    }.should fail_with("expected RuntimeError with \"example message\" but nothing was raised")
  end
  
  it "fails if incorrect error is raised" do
    lambda {
      lambda { raise }.should raise_error(NameError, "example message")
    }.should fail_with("expected NameError with \"example message\", got RuntimeError")
  end
  
  it "fails if correct error is raised with incorrect message" do
    lambda {
      lambda { raise RuntimeError.new("not the example message") }.should raise_error(RuntimeError, "example message")
    }.should fail_with(/expected RuntimeError with \"example message\", got #<RuntimeError: not the example message/)
  end
end

describe "should raise_error(NamedError, error_message) { |err| ... }" do
  it "yields exception if named error is raised with same message" do
    ran = false

    lambda {
      raise "example message"
    }.should raise_error(RuntimeError, "example message") { |err|
      ran = true
      err.class.should == RuntimeError
      err.message.should == "example message"
    }

    ran.should == true
  end

  it "yielded block fails on it's own right" do
    ran, passed = false, false

    lambda {
      lambda {
        raise "example message"
      }.should raise_error(RuntimeError, "example message") { |err|
        ran = true
        5.should == 4
        passed = true
      }
    }.should fail_with(/expected: 4/m)

    ran.should == true
    passed.should == false
  end

  it "does NOT yield exception if no error was thrown" do
    ran = false

    lambda {
      lambda {}.should raise_error(RuntimeError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected RuntimeError with \"example message\" but nothing was raised")

    ran.should == false
  end

  it "does not yield exception if error class is not matched" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should raise_error(SyntaxError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected SyntaxError with \"example message\", got #<RuntimeError: example message>")

    ran.should == false
  end

  it "does NOT yield exception if error message is not matched" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should raise_error(RuntimeError, "different message") { |err|
        ran = true
      }
    }.should fail_with("expected RuntimeError with \"different message\", got #<RuntimeError: example message>")

    ran.should == false
  end
end

describe "should_not raise_error(NamedError, error_message) { |err| ... }" do
  it "passes if nothing is raised" do
    ran = false

    lambda {}.should_not raise_error(RuntimeError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "passes if a different error is raised" do
    ran = false

    lambda { raise }.should_not raise_error(NameError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "passes if same error is raised with different message" do
    ran = false

    lambda {
      raise RuntimeError.new("not the example message")
    }.should_not raise_error(RuntimeError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "fails if named error is raised with same message" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should_not raise_error(RuntimeError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected no RuntimeError with \"example message\", got #<RuntimeError: example message>")

    ran.should == false
  end
end

describe "should_not raise_error(NamedError, error_message) with String" do
  it "passes if nothing is raised" do
    lambda {}.should_not raise_error(RuntimeError, "example message")
  end
  
  it "passes if a different error is raised" do
    lambda { raise }.should_not raise_error(NameError, "example message")
  end
  
  it "passes if same error is raised with different message" do
    lambda { raise RuntimeError.new("not the example message") }.should_not raise_error(RuntimeError, "example message")
  end
  
  it "fails if named error is raised with same message" do
    lambda {
      lambda { raise "example message" }.should_not raise_error(RuntimeError, "example message")
    }.should fail_with("expected no RuntimeError with \"example message\", got #<RuntimeError: example message>")
  end
end

describe "should raise_error(NamedError, error_message) with Regexp" do
  it "passes if named error is raised with matching message" do
    lambda { raise "example message" }.should raise_error(RuntimeError, /ample mess/)
  end
  
  it "fails if nothing is raised" do
    lambda {
      lambda {}.should raise_error(RuntimeError, /ample mess/)
    }.should fail_with("expected RuntimeError with message matching /ample mess/ but nothing was raised")
  end
  
  it "fails if incorrect error is raised" do
    lambda {
      lambda { raise }.should raise_error(NameError, /ample mess/)
    }.should fail_with("expected NameError with message matching /ample mess/, got RuntimeError")
  end
  
  it "fails if correct error is raised with incorrect message" do
    lambda {
      lambda { raise RuntimeError.new("not the example message") }.should raise_error(RuntimeError, /less than ample mess/)
    }.should fail_with("expected RuntimeError with message matching /less than ample mess/, got #<RuntimeError: not the example message>")
  end
end

describe "should_not raise_error(NamedError, error_message) with Regexp" do
  it "passes if nothing is raised" do
    lambda {}.should_not raise_error(RuntimeError, /ample mess/)
  end
  
  it "passes if a different error is raised" do
    lambda { raise }.should_not raise_error(NameError, /ample mess/)
  end
  
  it "passes if same error is raised with non-matching message" do
    lambda { raise RuntimeError.new("non matching message") }.should_not raise_error(RuntimeError, /ample mess/)
  end
  
  it "fails if named error is raised with matching message" do
    lambda {
      lambda { raise "example message" }.should_not raise_error(RuntimeError, /ample mess/)
    }.should fail_with("expected no RuntimeError with message matching /ample mess/, got #<RuntimeError: example message>")
  end
end
