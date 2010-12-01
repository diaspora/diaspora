require 'capybara/spec/test_app'
require 'nokogiri'

Dir[File.dirname(__FILE__)+'/session/*'].each { |group| 
  require group
}

shared_examples_for "session" do
  def extract_results(session)
    YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  end

  describe '#app' do
    it "should remember the application" do
      @session.app.should == TestApp
    end
  end

  describe '#visit' do
    it "should fetch a response from the driver" do
      @session.visit('/')
      @session.body.should include('Hello world!')
      @session.visit('/foo')
      @session.body.should include('Another World')
    end
  end
  
  describe '#body' do
    it "should return the unmodified page body" do
      @session.visit('/')
      @session.body.should include('Hello world!')
    end
  end
  
  describe '#source' do
    it "should return the unmodified page source" do
      @session.visit('/')
      @session.source.should include('Hello world!')
    end
  end

  describe '#scope_to' do
    let(:scope) { @session.scope_to("//p[@id='first']") }
    let(:more_scope) { scope.scope_to("//a[@id='foo']") }

    before do
      @session.visit('/with_html')
    end

    it 'has a simple link' do
      scope.should have_xpath("//a[@class='simple']")
    end

    it 'does not have a redirect link' do
      scope.should have_no_xpath("//a[@id='red']")
    end

    it 'does have a redirect link' do
      @session.should have_xpath("//a[@id='red']")
    end

    it 'does not share scopes' do
      @session.should have_xpath("//a[@id='red']")
      scope.should have_no_xpath("//a[@id='red']")
      @session.should have_xpath("//a[@id='red']")
    end

    context 'more_scope' do
      it 'has the text for foo' do
        more_scope.should have_content('ullamco')
      end

      it 'does not have a simple link' do
        more_scope.should have_no_xpath("//a[@class='simple']")
      end

      it 'has not overridden scope' do
        scope.should have_xpath("//a[@class='simple']")
      end

      it 'has not overridden session' do
        @session.should have_xpath("//p[@id='second']")
      end
    end

  end

  it_should_behave_like "all"
  it_should_behave_like "attach_file"
  it_should_behave_like "check"
  it_should_behave_like "choose"
  it_should_behave_like "click"
  it_should_behave_like "click_button"
  it_should_behave_like "click_link"
  it_should_behave_like "fill_in"
  it_should_behave_like "find_button"
  it_should_behave_like "find_field"
  it_should_behave_like "find_link"
  it_should_behave_like "find_by_id"
  it_should_behave_like "find"
  it_should_behave_like "has_content"
  it_should_behave_like "has_css"
  it_should_behave_like "has_css"
  it_should_behave_like "has_xpath"
  it_should_behave_like "has_link"
  it_should_behave_like "has_button"
  it_should_behave_like "has_field"
  it_should_behave_like "has_select"
  it_should_behave_like "has_table"
  it_should_behave_like "select"
  it_should_behave_like "uncheck"
  it_should_behave_like "unselect"
  it_should_behave_like "locate"
  it_should_behave_like "within"
  it_should_behave_like "current_url"
end


describe Capybara::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      running {
        Capybara::Session.new(:quox, TestApp).driver
      }.should raise_error(Capybara::DriverNotFoundError)
    end
  end
end
