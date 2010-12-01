shared_examples_for "all" do
  describe '#all' do
    before do
      @session.visit('/with_html')
    end

    it "should find all elements using the given locator" do
      @session.all('//p').should have(3).elements
      @session.all('//h1').first.text.should == 'This is a test'
      @session.all("//input[@id='test_field']").first[:value].should == 'monkey'
    end

    it "should return an empty array when nothing was found" do
      @session.all('//div[@id="nosuchthing"]').should be_empty
    end

    it "should accept an XPath instance" do
      @session.visit('/form')
      @xpath = Capybara::XPath.text_field('Name')
      @result = @session.all(@xpath).map { |r| r.value }
      @result.should include('Smith', 'John', 'John Smith')
    end

    context "with css selectors" do
      it "should find the first element using the given locator" do
        @session.all(:css, 'h1').first.text.should == 'This is a test'
        @session.all(:css, "input[id='test_field']").first[:value].should == 'monkey'
      end
    end

    context "with xpath selectors" do
      it "should find the first element using the given locator" do
        @session.all(:xpath, '//h1').first.text.should == 'This is a test'
        @session.all(:xpath, "//input[@id='test_field']").first[:value].should == 'monkey'
      end
    end

    context "with css as default selector" do
      before { Capybara.default_selector = :css }
      it "should find the first element using the given locator" do
        @session.all('h1').first.text.should == 'This is a test'
        @session.all("input[id='test_field']").first[:value].should == 'monkey'
      end
      after { Capybara.default_selector = :xpath }
    end

    context "with visible filter" do
      after { Capybara.ignore_hidden_elements = false }
      it "should only find visible nodes" do
        @session.all("//a[@title='awesome title']").should have(2).elements
        @session.all("//a[@title='awesome title']", :visible => true).should have(1).elements
        Capybara.ignore_hidden_elements = true
        @session.all("//a[@title='awesome title']").should have(1).elements
      end
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find any element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.all('//li').should have(2).elements
        end
      end
    end
  end
end
