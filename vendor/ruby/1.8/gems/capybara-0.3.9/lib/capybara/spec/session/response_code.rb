shared_examples_for "session with status code support" do
  describe '#status_code' do
    it "should return response codes" do
      @session.visit('/with_simple_html')     
      @session.status_code.should == 200
    end
  end
end

shared_examples_for "session without status code support" do
  describe "#status_code" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.status_code
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
