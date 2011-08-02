shared_examples_for "click" do
  describe '#click' do
    it "should click on a link" do
      @session.visit('/with_html')
      @session.click('labore')
      @session.body.should include('Bar')
    end

    it "should click on a button" do
      @session.visit('/form')
      @session.click('awe123')
      extract_results(@session)['first_name'].should == 'John'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        @session.visit('/with_html')
        running do
          @session.click('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
