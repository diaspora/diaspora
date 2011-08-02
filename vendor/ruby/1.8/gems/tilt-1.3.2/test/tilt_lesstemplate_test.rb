require 'contest'
require 'tilt'

begin
  require 'less'

  class LessTemplateTest < Test::Unit::TestCase
    test "is registered for '.less' files" do
      assert_equal Tilt::LessTemplate, Tilt['test.less']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      assert_equal ".bg, #main { background-color: #0000ff; }\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      3.times { assert_equal ".bg, #main { background-color: #0000ff; }\n", template.render }
    end
  end

rescue LoadError => boom
  warn "Tilt::LessTemplate (disabled)\n"
end
