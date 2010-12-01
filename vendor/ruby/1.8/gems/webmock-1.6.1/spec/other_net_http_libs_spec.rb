require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "loading other Net::HTTP based libraries" do

  def capture_output_from_requiring(libs, additional_code = "")
    requires = libs.map { |lib| "require '#{lib}'" }
    requires << " require 'addressable/uri'"
    requires << " require 'crack'"
    requires = requires.join("; ")
    webmock_dir = "#{File.dirname(__FILE__)}/../lib"
    vendor_dirs = Dir["#{File.dirname(__FILE__)}/vendor/*/lib"]
    load_path_opts = vendor_dirs.unshift(webmock_dir).map { |dir| "-I#{dir}" }.join(" ")

    # TODO: use the same Ruby executable that this test was invoked with
    `ruby #{load_path_opts} -e "#{requires}; #{additional_code}" 2>&1 | cat`
  end

  it "should requiring right http connection before webmock and then connecting does not print warning" do
    additional_code = "Net::HTTP.start('example.com')"
    output = capture_output_from_requiring %w(right_http_connection webmock), additional_code
    output.should be_empty
  end

  it "should requiring right http connection after webmock and then connecting prints warning" do
    additional_code = "Net::HTTP.start('example.com')"
    output = capture_output_from_requiring %w(webmock right_http_connection), additional_code
    output.should match(%r(Warning: RightHttpConnection has to be required before WebMock is required !!!))
  end

end
