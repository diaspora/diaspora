#--
# (c) Copyright 2007-2008 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'net/http/post/multipart'

class Net::HTTP::Post::MultiPartTest < Test::Unit::TestCase
  TEMP_FILE = "temp.txt"

  HTTPPost = Struct.new("HTTPPost", :content_length, :body_stream, :content_type)
  HTTPPost.module_eval do
    def set_content_type(type, params = {})
      self.content_type = type + params.map{|k,v|"; #{k}=#{v}"}.join('')
    end
  end

  def teardown
    File.delete(TEMP_FILE) rescue nil
  end

  def test_form_multipart_body
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    @io = File.open(TEMP_FILE)
    @io = UploadIO.new @io, "text/plain", TEMP_FILE
    assert_results Net::HTTP::Post::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end
  def test_form_multipart_body_put
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    @io = File.open(TEMP_FILE)
    @io = UploadIO.new @io, "text/plain", TEMP_FILE
    assert_results Net::HTTP::Put::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end

  def test_form_multipart_body_with_stringio
    @io = StringIO.new("1234567890")
    @io = UploadIO.new @io, "text/plain", TEMP_FILE
    assert_results Net::HTTP::Post::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end

  def assert_results(post)
    assert post.content_length && post.content_length > 0
    assert post.body_stream
    assert_equal "multipart/form-data; boundary=#{Multipartable::DEFAULT_BOUNDARY}", post['content-type']
    body = post.body_stream.read
    boundary_regex = Regexp.quote Multipartable::DEFAULT_BOUNDARY
    assert body =~ /1234567890/
    # ensure there is at least one boundary
    assert body =~ /^--#{boundary_regex}\r\n/
    # ensure there is an epilogue
    assert body =~ /^--#{boundary_regex}--\r\n/
    assert body =~ /text\/plain/
  end
end
