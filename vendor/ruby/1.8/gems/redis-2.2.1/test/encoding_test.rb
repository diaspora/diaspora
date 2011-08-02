# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

test "returns properly encoded strings" do |r|
  with_external_encoding("UTF-8") do
    r.set "foo", "שלום"

    assert "Shalom שלום" == "Shalom " + r.get("foo")
  end
end if defined?(Encoding)

