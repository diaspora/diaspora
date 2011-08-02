# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

test "SAVE and BGSAVE" do |r|
  assert_nothing_raised do
    r.save
  end

  assert_nothing_raised do
    r.bgsave
  end
end

test "LASTSAVE" do |r|
  assert Time.at(r.lastsave) <= Time.now
end

