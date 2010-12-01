shared_examples_for "session with headers support" do
  describe '#response_headers' do
    it "should return response headers" do
      @session.visit('/with_simple_html')     
      @session.response_headers['Content-Type'].should == 'text/html'
    end
  end
end

shared_examples_for "session without headers support" do
  describe "#response_headers" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.response_headers
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
