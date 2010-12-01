require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe WebMock::RequestExecutionVerifier do
  before(:each) do
    @verifier = WebMock::RequestExecutionVerifier.new
    @request_pattern = mock(WebMock::RequestPattern, :to_s => "www.example.com")
    @verifier.request_pattern = @request_pattern
    WebMock::RequestRegistry.instance.stub(:to_s).and_return("executed requests")
    @executed_requests_info = "\n\nThe following requests were made:\n\nexecuted requests\n" + "="*60
  end


  describe "failure message" do

    it "should report failure message" do
      @verifier.times_executed = 0
      @verifier.expected_times_executed = 2
      expected_text = "The request www.example.com was expected to execute 2 times but it executed 0 times"
      expected_text << @executed_requests_info
      @verifier.failure_message.should == expected_text  
    end

    it "should report failure message correctly when executed times is one" do
      @verifier.times_executed = 1
      @verifier.expected_times_executed = 1
      expected_text = "The request www.example.com was expected to execute 1 time but it executed 1 time"
      expected_text << @executed_requests_info
      @verifier.failure_message.should == expected_text
    end

  end
  
  describe "negative failure message" do

    it "should report failure message if it executed number of times specified" do
      @verifier.times_executed = 2
      @verifier.expected_times_executed = 2
      expected_text = "The request www.example.com was not expected to execute 2 times but it executed 2 times"
      expected_text << @executed_requests_info
      @verifier.negative_failure_message.should == expected_text
    end

    it "should report failure message when not expected request but it executed" do
      @verifier.times_executed = 1
      expected_text = "The request www.example.com was expected to execute 0 times but it executed 1 time"
      expected_text << @executed_requests_info
      @verifier.negative_failure_message.should == expected_text
    end

  end

  describe "matches?" do

    it "should succeed if request was executed expected number of times" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 10
      @verifier.matches?.should be_true
    end

    it "should fail if request was not executed expected number of times" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 5
      @verifier.matches?.should be_false
    end

  end
  
  describe "does_not_match?" do

    it "should fail if request executed expected number of times" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 10
      @verifier.does_not_match?.should be_false     
    end
    
    it "should succeed if request was not executed at all and expected number of times was not set" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(0)
      @verifier.does_not_match?.should be_true      
    end
    
    it "should fail if request was executed and expected number of times was not set" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(1)
      @verifier.does_not_match?.should be_false     
    end

    it "should succeed if request was not executed expected number of times" do
      WebMock::RequestRegistry.instance.
        should_receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 5
      @verifier.does_not_match?.should be_true
    end

  end

end
