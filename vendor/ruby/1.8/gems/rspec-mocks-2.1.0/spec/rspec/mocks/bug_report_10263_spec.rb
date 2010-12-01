describe "Mock" do
  before do
    @double = double("test double")
  end
  
  specify "when one example has an expectation (non-mock) inside the block passed to the mock" do
    @double.should_receive(:msg) do |b|
      b.should be_true #this call exposes the problem
    end
    begin
      @double.msg(false)
    rescue Exception
    end
  end
  
  specify "then the next example should behave as expected instead of saying" do
    @double.should_receive(:foobar)
    @double.foobar
    @double.rspec_verify
    begin
      @double.foobar
    rescue Exception => e
      e.message.should == "Double \"test double\" received unexpected message :foobar with (no args)"
    end
  end 
end

