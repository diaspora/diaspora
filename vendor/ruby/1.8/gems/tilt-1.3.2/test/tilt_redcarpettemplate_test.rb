require 'contest'
require 'tilt'

begin
  require 'redcarpet'

  class RedcarpetTemplateTest < Test::Unit::TestCase
    test "registered for '.md' files" do
      assert Tilt.mappings['md'].include?(Tilt::RedcarpetTemplate)
    end

    test "registered for '.mkd' files" do
      assert Tilt.mappings['mkd'].include?(Tilt::RedcarpetTemplate)
    end

    test "registered for '.markdown' files" do
      assert Tilt.mappings['markdown'].include?(Tilt::RedcarpetTemplate)
    end

    test "registered above BlueCloth" do
      %w[md mkd markdown].each do |ext|
        mappings = Tilt.mappings[ext]
        blue_idx = mappings.index(Tilt::BlueClothTemplate)
        rdis_idx = mappings.index(Tilt::RedcarpetTemplate)
        assert rdis_idx < blue_idx,
          "#{rdis_idx} should be lower than #{blue_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::RedcarpetTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RedcarpetTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end

    test "smartypants when :smart is set" do
      template = Tilt::RedcarpetTemplate.new(:smart => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_equal "<p>OKAY &mdash; &lsquo;Smarty Pants&rsquo;</p>\n",
        template.render
    end

    test "stripping HTML when :filter_html is set" do
      template = Tilt::RedcarpetTemplate.new(:filter_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO WORLD</p>\n", template.render
    end
  end
rescue LoadError => boom
  warn "Tilt::RedcarpetTemplate (disabled)\n"
end
