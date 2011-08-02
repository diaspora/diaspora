require 'common'

module Etc; end

class Protocol::V06::TestAttributes < Net::SFTP::TestCase
  def test_from_buffer_should_correctly_parse_buffer_and_return_attribute_object
    attributes = attributes_factory.from_buffer(full_buffer)

    assert_equal 9, attributes.type
    assert_equal 1234567890, attributes.size
    assert_equal 2345678901, attributes.allocation_size
    assert_equal "jamis", attributes.owner
    assert_equal "users", attributes.group
    assert_equal 0755, attributes.permissions
    assert_equal 1234567890, attributes.atime
    assert_equal 12345, attributes.atime_nseconds
    assert_equal 2345678901, attributes.createtime
    assert_equal 23456, attributes.createtime_nseconds
    assert_equal 3456789012, attributes.mtime
    assert_equal 34567, attributes.mtime_nseconds
    assert_equal 4567890123, attributes.ctime
    assert_equal 45678, attributes.ctime_nseconds

    assert_equal 2, attributes.acl.length

    assert_equal 1, attributes.acl.first.type
    assert_equal 2, attributes.acl.first.flag
    assert_equal 3, attributes.acl.first.mask
    assert_equal "foo", attributes.acl.first.who

    assert_equal 4, attributes.acl.last.type
    assert_equal 5, attributes.acl.last.flag
    assert_equal 6, attributes.acl.last.mask
    assert_equal "bar", attributes.acl.last.who

    assert_equal 0x12341234, attributes.attrib_bits
    assert_equal 0x23452345, attributes.attrib_bits_valid
    assert_equal 0x3, attributes.text_hint
    assert_equal "text/html", attributes.mime_type
    assert_equal 144, attributes.link_count
    assert_equal "an untranslated name", attributes.untranslated_name

    assert_equal "second", attributes.extended["first"]
  end

  def test_from_buffer_should_correctly_parse_buffer_with_attribute_subset_and_return_attribute_object
    buffer = Net::SSH::Buffer.from(:long, 0x4, :byte, 1, :long, 0755)

    attributes = attributes_factory.from_buffer(buffer)

    assert_equal 1, attributes.type
    assert_equal 0755, attributes.permissions

    assert_nil attributes.size
    assert_nil attributes.allocation_size
    assert_nil attributes.owner
    assert_nil attributes.group
    assert_nil attributes.atime
    assert_nil attributes.atime_nseconds
    assert_nil attributes.createtime
    assert_nil attributes.createtime_nseconds
    assert_nil attributes.mtime
    assert_nil attributes.mtime_nseconds
    assert_nil attributes.ctime
    assert_nil attributes.ctime_nseconds
    assert_nil attributes.acl
    assert_nil attributes.attrib_bits
    assert_nil attributes.attrib_bits_valid
    assert_nil attributes.text_hint
    assert_nil attributes.mime_type
    assert_nil attributes.link_count
    assert_nil attributes.untranslated_name
    assert_nil attributes.extended
  end

  def test_attributes_to_s_should_build_binary_representation
    attributes = attributes_factory.new(
      :type => 9,
      :size => 1234567890, :allocation_size => 2345678901,
      :owner  => "jamis", :group => "users",
      :permissions => 0755,
      :atime => 1234567890, :atime_nseconds => 12345,
      :createtime => 2345678901, :createtime_nseconds => 23456,
      :mtime => 3456789012, :mtime_nseconds => 34567,
      :ctime => 4567890123, :ctime_nseconds => 45678,
      :acl => [attributes_factory::ACL.new(1,2,3,"foo"),
               attributes_factory::ACL.new(4,5,6,"bar")],
      :attrib_bits => 0x12341234, :attrib_bits_valid => 0x23452345,
      :text_hint => 0x3, :mime_type => "text/html",
      :link_count => 144, :untranslated_name => "an untranslated name",
      :extended => { "first" => "second" })

    assert_equal full_buffer.to_s, attributes.to_s
  end

  def test_attributes_to_s_should_build_binary_representation_when_subset_is_present
    attributes = attributes_factory.new(:permissions => 0755)
    assert_equal Net::SSH::Buffer.from(:long, 0x4, :byte, 1, :long, 0755).to_s, attributes.to_s
  end

  private

    def full_buffer
      Net::SSH::Buffer.from(:long, 0x8000fffd,
        :byte, 9, :int64, 1234567890, :int64, 2345678901,
        :string, "jamis", :string, "users",
        :long, 0755,
        :int64, 1234567890, :long, 12345,
        :int64, 2345678901, :long, 23456,
        :int64, 3456789012, :long, 34567,
        :int64, 4567890123, :long, 45678,
        :string, raw(:long, 2,
          :long, 1, :long, 2, :long, 3, :string, "foo",
          :long, 4, :long, 5, :long, 6, :string, "bar"),
        :long, 0x12341234, :long, 0x23452345,
        :byte, 0x3, :string, "text/html", :long, 144,
        :string, "an untranslated name",
        :long, 1, :string, "first", :string, "second")
    end

    def attributes_factory
      Net::SFTP::Protocol::V06::Attributes
    end
end