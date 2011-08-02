require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'capybara/save_and_open_page'
require 'launchy'
describe Capybara::SaveAndOpenPage do
  describe "#save_save_and_open_page" do
    before do
      @time = Time.new.strftime("%Y%m%d%H%M%S")

      @temp_file = mock("FILE")
      @temp_file.stub!(:write)
      @temp_file.stub!(:close)
      
      @html = <<-HTML
        <html>
          <head>
          </head>
          <body>
            <h1>test</h1>
          </body>
        <html>
      HTML

      Launchy::Browser.stub(:run)
    end

    describe "defaults" do
      before do
        @name = "capybara-#{@time}.html"
        
        @temp_file.stub!(:path).and_return(@name)

        File.should_receive(:exist?).and_return true
        File.should_receive(:new).and_return @temp_file
      end
      
      it "should create a new temporary file" do
        @temp_file.should_receive(:write).with @html
        Capybara::SaveAndOpenPage.save_and_open_page @html
      end

      it "should open the file in the browser" do
        Capybara::SaveAndOpenPage.should_receive(:open_in_browser).with(@name)
        Capybara::SaveAndOpenPage.save_and_open_page @html
      end
    end
    
    describe "custom output path" do
      before do
        @custom_path = File.join('tmp', 'capybara')
        @custom_name = File.join(@custom_path, "capybara-#{@time}.html")

        @temp_file.stub!(:path).and_return(@custom_name)
        
        Capybara.should_receive(:save_and_open_page_path).at_least(:once).and_return(@custom_path)
      end
      
      it "should create a new temporary file in the custom path" do
        File.should_receive(:directory?).and_return true
        File.should_receive(:exist?).and_return true
        File.should_receive(:new).and_return @temp_file
        
        @temp_file.should_receive(:write).with @html
        Capybara::SaveAndOpenPage.save_and_open_page @html
      end
      
      it "should open the file - in the custom path - in the browser" do
        Capybara::SaveAndOpenPage.should_receive(:open_in_browser).with(@custom_name)
        Capybara::SaveAndOpenPage.save_and_open_page @html
      end
      
      it "should be possible to configure output path" do
        Capybara.should respond_to(:save_and_open_page_path)
        default_setting = Capybara.save_and_open_page_path
        lambda {
            Capybara.save_and_open_page_path = File.join('tmp', 'capybara')
            Capybara.save_and_open_page_path.should == File.join('tmp', 'capybara')
          }.should_not raise_error
        Capybara.save_and_open_page_path = default_setting
      end
    end
  end
end
