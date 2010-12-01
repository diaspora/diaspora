shared_examples_for "locate" do
  describe '#locate' do
    before do
      @session.visit('/with_html')
    end

    it "should find the first element using the given locator" do
      @session.locate('//h1').text.should == 'This is a test'
      @session.locate("//input[@id='test_field']")[:value].should == 'monkey'
    end

    context "with css selectors" do
      it "should find the first element using the given locator" do
        @session.locate(:css, 'h1').text.should == 'This is a test'
        @session.locate(:css, "input[id='test_field']")[:value].should == 'monkey'
      end
    end

    context "with xpath selectors" do
      it "should find the first element using the given locator" do
        @session.locate(:xpath, '//h1').text.should == 'This is a test'
        @session.locate(:xpath, "//input[@id='test_field']")[:value].should == 'monkey'
      end
    end

    context "with css as default selector" do
      before { Capybara.default_selector = :css }
      it "should find the first element using the given locator" do
        @session.locate('h1').text.should == 'This is a test'
        @session.locate("input[id='test_field']")[:value].should == 'monkey'
      end
      after { Capybara.default_selector = :xpath }
    end

    it "should raise ElementNotFound with specified fail message if nothing was found" do
      running do
        @session.locate(:xpath, '//div[@id="nosuchthing"]', 'arghh').should be_nil
      end.should raise_error(Capybara::ElementNotFound, "arghh")
    end

    it "should raise ElementNotFound with a useful default message if nothing was found" do
      running do
        @session.locate(:xpath, '//div[@id="nosuchthing"]').should be_nil
      end.should raise_error(Capybara::ElementNotFound, "Unable to locate '//div[@id=\"nosuchthing\"]'")
    end

    it "should accept an XPath instance and respect the order of paths" do
      @session.visit('/form')
      @xpath = Capybara::XPath.text_field('Name')
      @session.locate(@xpath).value.should == 'John Smith'
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find the first element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.locate('//li').text.should =~ /With Simple HTML/
        end        
      end
    end
  end
end
