require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

Faraday::CompositeReadIO.send :attr_reader, :ios

class MultipartTest < Faraday::TestCase
  def setup
    @app = Faraday::Adapter.new nil
    @env = {:request_headers => {}}
  end

  def test_processes_nested_body
    # assume params are out of order
    regexes = [
      /name\=\"a\"/,
      /name=\"b\[c\]\"\; filename\=\"multipart_test\.rb\"/,
      /name=\"b\[d\]\"/]
    @env[:body] = {:a => 1, :b => {:c => Faraday::UploadIO.new(__FILE__, 'text/x-ruby'), :d => 2}}
    @app.process_body_for_request @env
    @env[:body].send(:ios).map(&:read).each do |io|
      if re = regexes.detect { |r| io =~ r }
        regexes.delete re
      end
    end
    assert_equal [], regexes
    assert_kind_of CompositeReadIO, @env[:body]
    assert_equal "%s;boundary=%s" %
      [Faraday::Adapter::MULTIPART_TYPE, Faraday::Adapter::DEFAULT_BOUNDARY],
      @env[:request_headers]['Content-Type']
  end

  def test_processes_nil_body
    @env[:body] = nil
    @app.process_body_for_request @env
    assert_nil @env[:body]
  end

  def test_processes_empty_body
    @env[:body] = ''
    @app.process_body_for_request @env
    assert_equal '', @env[:body]
  end

  def test_processes_string_body
    @env[:body] = 'abc'
    @app.process_body_for_request @env
    assert_equal 'abc', @env[:body]
  end
end
