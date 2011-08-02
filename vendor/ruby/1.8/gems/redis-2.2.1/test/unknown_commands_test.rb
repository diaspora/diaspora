 # encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

test "should try to work" do |r|
  assert_raise RuntimeError do
    r.not_yet_implemented_command
  end
end

