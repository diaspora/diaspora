require "test/unit"
require "json"
require "haml"

class HamlTest < Test::Unit::TestCase
  contexts = JSON.parse(File.read(File.dirname(__FILE__) + "/tests.json"))
  contexts.each do |context|
    context[1].each do |name, test|
      class_eval(<<-EOTEST)
        def test_#{name.gsub(/\s+|[^a-zA-Z0-9_]/, "_")}
          locals = Hash[*(#{test}["locals"] || {}).collect {|k, v| [k.to_sym, v] }.flatten]
          options = Hash[*(#{test}["config"] || {}).collect {|k, v| [k.to_sym, v.to_sym] }.flatten]
          engine = Haml::Engine.new(#{test}["haml"], options)
          assert_equal(engine.render(Object.new, locals).chomp, #{test}["html"])
        end
      EOTEST
    end
  end
end
