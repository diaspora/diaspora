# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{json}
  s.version = "1.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = %q{2010-08-09}
  s.default_executable = %q{edit_json.rb}
  s.description = %q{This is a JSON implementation as a Ruby extension in C.}
  s.email = %q{flori@ping.de}
  s.executables = ["edit_json.rb", "prettify_json.rb"]
  s.extensions = ["ext/json/ext/generator/extconf.rb", "ext/json/ext/parser/extconf.rb"]
  s.extra_rdoc_files = ["README"]
  s.files = ["CHANGES", "bin/edit_json.rb", "bin/prettify_json.rb", "VERSION", "GPL", "TODO", "README", "benchmarks/ohai.json", "benchmarks/parser_benchmark.rb", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkComparison.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkComparison.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe-autocorrelation.dat", "benchmarks/generator2_benchmark.rb", "benchmarks/generator_benchmark.rb", "benchmarks/parser2_benchmark.rb", "benchmarks/ohai.ruby", "ext/json/ext/generator/extconf.rb", "ext/json/ext/generator/generator.c", "ext/json/ext/generator/generator.h", "ext/json/ext/parser/extconf.rb", "ext/json/ext/parser/parser.rl", "ext/json/ext/parser/parser.h", "ext/json/ext/parser/parser.c", "Rakefile", "tools/fuzz.rb", "tools/server.rb", "lib/json.rb", "lib/json/json.xpm", "lib/json/Key.xpm", "lib/json/String.xpm", "lib/json/Numeric.xpm", "lib/json/Hash.xpm", "lib/json/add/rails.rb", "lib/json/add/core.rb", "lib/json/common.rb", "lib/json/Array.xpm", "lib/json/FalseClass.xpm", "lib/json/pure/generator.rb", "lib/json/pure/parser.rb", "lib/json/TrueClass.xpm", "lib/json/pure.rb", "lib/json/version.rb", "lib/json/ext.rb", "lib/json/editor.rb", "lib/json/NilClass.xpm", "data/example.json", "data/index.html", "data/prototype.js", "tests/test_json_encoding.rb", "tests/test_json_addition.rb", "tests/fixtures/pass16.json", "tests/fixtures/fail4.json", "tests/fixtures/fail1.json", "tests/fixtures/fail28.json", "tests/fixtures/fail8.json", "tests/fixtures/fail19.json", "tests/fixtures/pass2.json", "tests/fixtures/pass26.json", "tests/fixtures/pass1.json", "tests/fixtures/fail3.json", "tests/fixtures/fail20.json", "tests/fixtures/pass3.json", "tests/fixtures/pass15.json", "tests/fixtures/fail12.json", "tests/fixtures/fail13.json", "tests/fixtures/fail22.json", "tests/fixtures/fail24.json", "tests/fixtures/fail9.json", "tests/fixtures/fail2.json", "tests/fixtures/fail14.json", "tests/fixtures/fail6.json", "tests/fixtures/fail21.json", "tests/fixtures/fail7.json", "tests/fixtures/pass17.json", "tests/fixtures/fail11.json", "tests/fixtures/fail25.json", "tests/fixtures/fail5.json", "tests/fixtures/fail18.json", "tests/fixtures/fail27.json", "tests/fixtures/fail10.json", "tests/fixtures/fail23.json", "tests/test_json_rails.rb", "tests/test_json.rb", "tests/test_json_generate.rb", "tests/test_json_unicode.rb", "tests/test_json_fixtures.rb", "COPYING", "install.rb"]
  s.homepage = %q{http://flori.github.com/json}
  s.rdoc_options = ["--title", "JSON implemention for Ruby", "--main", "README"]
  s.require_paths = ["ext/json/ext", "ext", "lib"]
  s.rubyforge_project = %q{json}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{JSON Implementation for Ruby}
  s.test_files = ["tests/test_json_encoding.rb", "tests/test_json_addition.rb", "tests/test_json_rails.rb", "tests/test_json.rb", "tests/test_json_generate.rb", "tests/test_json_unicode.rb", "tests/test_json_fixtures.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
