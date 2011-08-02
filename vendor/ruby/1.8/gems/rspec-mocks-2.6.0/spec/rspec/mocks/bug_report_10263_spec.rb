describe "Double" do
  let(:test_double) { double }

  specify "when one example has an expectation inside the block passed to should_receive" do
    test_double.should_receive(:msg) do |arg|
      arg.should be_true #this call exposes the problem
    end
    begin
      test_double.msg(false)
    rescue Exception
    end
  end
  
  specify "then the next example should behave as expected instead of saying" do
    test_double.should_receive(:foobar)
    test_double.foobar
    test_double.rspec_verify
    begin
      test_double.foobar
    rescue Exception => e
      e.message.should == "Double received unexpected message :foobar with (no args)"
    end
  end 
end

