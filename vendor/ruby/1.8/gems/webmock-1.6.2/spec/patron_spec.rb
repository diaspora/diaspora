require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'webmock_shared'

unless RUBY_PLATFORM =~ /java/
  require 'patron_spec_helper'
  require 'tmpdir'
  require 'fileutils'

  describe "Webmock with Patron" do
    include PatronSpecHelper

    it_should_behave_like "WebMock"

    describe "when custom functionality is used" do
      before(:each) do
        @sess = Patron::Session.new
        @sess.base_url = "http://www.example.com"
      end

      describe "file requests" do

        before(:each) do
          @dir_path = Dir.mktmpdir('webmock-')
          @file_path = File.join(@dir_path, "webmock_temp_test_file")
          FileUtils.rm_rf(@file_path) if File.exists?(@file_path)
        end

        after(:each) do
          FileUtils.rm_rf(@dir_path) if File.exist?(@dir_path)
        end


        it "should work with get_file" do
          stub_http_request(:get, "www.example.com").to_return(:body => "abc")
          @sess.get_file("/", @file_path)
          File.read(@file_path).should == "abc"
        end

        it "should raise same error as Patron if file is not readable for get request" do
          stub_http_request(:get, "www.example.com")
          lambda {
            @sess.get_file("/", "/non_existing_file")
          }.should raise_error(ArgumentError, "Unable to open specified file.")
        end

        it "should work with put_file" do
          File.open(@file_path, "w") {|f| f.write "abc"}
          stub_http_request(:put, "www.example.com").with(:body => "abc")
          @sess.put_file("/", @file_path)
        end

        it "should work with post_file" do
          File.open(@file_path, "w") {|f| f.write "abc"}
          stub_http_request(:post, "www.example.com").with(:body => "abc")
          @sess.post_file("/", @file_path)
        end

        it "should raise same error as Patron if file is not readable for post request" do
          stub_http_request(:post, "www.example.com").with(:body => "abc")
          lambda {
            @sess.post_file("/", "/non_existing_file")
          }.should raise_error(ArgumentError, "Unable to open specified file.")
        end

      end

      describe "handling errors same way as patron" do
        it "should raise error if put request has neither upload_data nor file_name" do
          stub_http_request(:post, "www.example.com")
          lambda {
            @sess.post("/", nil)
          }.should raise_error(ArgumentError, "Must provide either data or a filename when doing a PUT or POST")
        end
      end

      it "should work with WebDAV copy request" do
        stub_http_request(:copy, "www.example.com/abc").with(:headers => {'Destination' => "/def"})
        @sess.copy("/abc", "/def")
      end
    end
  end
end
