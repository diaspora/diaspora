# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{json_pure}
  s.version = "1.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = %q{2011-06-20}
  s.description = %q{This is a JSON implementation in pure Ruby.}
  s.email = %q{flori@ping.de}
  s.executables = ["edit_json.rb", "prettify_json.rb"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["tests/test_json_string_matching.rb", "tests/test_json_fixtures.rb", "tests/setup_variant.rb", "tests/fixtures/fail6.json", "tests/fixtures/fail9.json", "tests/fixtures/fail10.json", "tests/fixtures/fail24.json", "tests/fixtures/fail28.json", "tests/fixtures/fail13.json", "tests/fixtures/fail4.json", "tests/fixtures/pass3.json", "tests/fixtures/fail11.json", "tests/fixtures/fail14.json", "tests/fixtures/fail3.json", "tests/fixtures/fail12.json", "tests/fixtures/pass16.json", "tests/fixtures/pass15.json", "tests/fixtures/fail20.json", "tests/fixtures/fail8.json", "tests/fixtures/pass2.json", "tests/fixtures/fail5.json", "tests/fixtures/fail1.json", "tests/fixtures/fail25.json", "tests/fixtures/pass17.json", "tests/fixtures/fail7.json", "tests/fixtures/pass26.json", "tests/fixtures/fail21.json", "tests/fixtures/pass1.json", "tests/fixtures/fail23.json", "tests/fixtures/fail18.json", "tests/fixtures/fail2.json", "tests/fixtures/fail22.json", "tests/fixtures/fail27.json", "tests/fixtures/fail19.json", "tests/test_json_unicode.rb", "tests/test_json_addition.rb", "tests/test_json_generate.rb", "tests/test_json_encoding.rb", "tests/test_json.rb", "COPYING", "TODO", "Rakefile", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkComparison.log", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkComparison.log", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser-autocorrelation.dat", "benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe-autocorrelation.dat", "benchmarks/parser2_benchmark.rb", "benchmarks/parser_benchmark.rb", "benchmarks/generator2_benchmark.rb", "benchmarks/generator_benchmark.rb", "benchmarks/ohai.ruby", "benchmarks/ohai.json", "lib/json/json.xpm", "lib/json/TrueClass.xpm", "lib/json/version.rb", "lib/json/Array.xpm", "lib/json/add/core.rb", "lib/json/add/rails.rb", "lib/json/common.rb", "lib/json/pure/generator.rb", "lib/json/pure/parser.rb", "lib/json/ext.rb", "lib/json/pure.rb", "lib/json/Key.xpm", "lib/json/FalseClass.xpm", "lib/json/editor.rb", "lib/json/Numeric.xpm", "lib/json/NilClass.xpm", "lib/json/String.xpm", "lib/json/Hash.xpm", "lib/json.rb", "Gemfile", "README.rdoc", "json_pure.gemspec", "GPL", "CHANGES", "bin/prettify_json.rb", "bin/edit_json.rb", "COPYING-json-jruby", "ext/json/ext/parser/parser.h", "ext/json/ext/parser/extconf.rb", "ext/json/ext/parser/parser.rl", "ext/json/ext/parser/parser.c", "ext/json/ext/generator/generator.c", "ext/json/ext/generator/extconf.rb", "ext/json/ext/generator/generator.h", "VERSION", "data/prototype.js", "data/index.html", "data/example.json", "json.gemspec", "java/src/json/ext/Parser.java", "java/src/json/ext/RuntimeInfo.java", "java/src/json/ext/GeneratorState.java", "java/src/json/ext/OptionsReader.java", "java/src/json/ext/ParserService.java", "java/src/json/ext/Parser.rl", "java/src/json/ext/StringEncoder.java", "java/src/json/ext/GeneratorService.java", "java/src/json/ext/Utils.java", "java/src/json/ext/StringDecoder.java", "java/src/json/ext/Generator.java", "java/src/json/ext/ByteListTranscoder.java", "java/src/json/ext/GeneratorMethods.java", "java/lib/bytelist-1.0.6.jar", "java/lib/jcodings.jar", "README-json-jruby.markdown", "install.rb", "json-java.gemspec", "tools/fuzz.rb", "tools/server.rb", "./tests/test_json_string_matching.rb", "./tests/test_json_fixtures.rb", "./tests/test_json_unicode.rb", "./tests/test_json_addition.rb", "./tests/test_json_generate.rb", "./tests/test_json_encoding.rb", "./tests/test_json.rb"]
  s.homepage = %q{http://flori.github.com/json}
  s.rdoc_options = ["--title", "JSON implemention for ruby", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{json}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{JSON Implementation for Ruby}
  s.test_files = ["./tests/test_json_string_matching.rb", "./tests/test_json_fixtures.rb", "./tests/test_json_unicode.rb", "./tests/test_json_addition.rb", "./tests/test_json_generate.rb", "./tests/test_json_encoding.rb", "./tests/test_json.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<permutation>, [">= 0"])
      s.add_development_dependency(%q<bullshit>, [">= 0"])
      s.add_development_dependency(%q<sdoc>, [">= 0"])
    else
      s.add_dependency(%q<permutation>, [">= 0"])
      s.add_dependency(%q<bullshit>, [">= 0"])
      s.add_dependency(%q<sdoc>, [">= 0"])
    end
  else
    s.add_dependency(%q<permutation>, [">= 0"])
    s.add_dependency(%q<bullshit>, [">= 0"])
    s.add_dependency(%q<sdoc>, [">= 0"])
  end
end
