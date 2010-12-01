require 'test/unit'
require 'gem_plugin'

include GemPlugin

class ATestPlugin < GemPlugin::Plugin "/stuff"
end

class First < GemPlugin::Plugin "/commands"
  def initialize(options = {})
    puts "First with options: #{options.inspect}"
  end
end

class Second < GemPlugin::Plugin "/commands"
  def initialize(options = {})
    puts "Second with options: #{options.inspect}"
  end
end

class Last < GemPlugin::Plugin "/commands"
  def initialize(options = {})
    puts "Last with options: #{options.inspect}"
  end
end


class PluginTest < Test::Unit::TestCase

  def setup
    @pmgr = Manager.instance
    @pmgr.load({"rails" => EXCLUDE})
    @categories = ["/commands"]
    @names = ["/first", "/second", "/last", "/atestplugin"]
  end

  def test_load_plugins
    puts "#{@pmgr.plugins.inspect}"
    @pmgr.plugins.each {|cat,plugins|
      plugins.each do |n,p|
        puts "TEST: #{cat}#{n}"
      end
    }

    @pmgr.load
    @pmgr.plugins.each do |cat,plugins|
      plugins.each do |n,p|
        STDERR.puts "#{cat}#{n}"
        plugin = @pmgr.create("#{cat}#{n}", options={"name" => p})
      end
    end
  end

  def test_similar_uris

    @pmgr.register("/test", "/testme", ATestPlugin)
    @pmgr.register("/test2", "/testme", ATestPlugin)

    assert_equal @pmgr.create("/test/testme").class, ATestPlugin
    assert_equal @pmgr.create("/test2/testme").class, ATestPlugin

  end


  def test_create
    last = @pmgr.create("/commands/last", "test" => "stuff")
    assert last != nil, "Didn't make the right plugin"
    first = @pmgr.create("/commands/last")
    assert first != nil, "Didn't make the right plugin"
  end

end
